param(
  [string]$ListenAddress = "172.17.48.1",
  [int]$ListenPort = 9224,
  [string]$TargetAddress = "127.0.0.1",
  [int]$TargetPort = 9222
)

$ErrorActionPreference = "Stop"
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($ListenAddress), $ListenPort)
$listener.Server.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)
$listener.Start()
Write-Host "Proxy listening on ${ListenAddress}:${ListenPort} -> ${TargetAddress}:${TargetPort}"

while ($true) {
  $client = $listener.AcceptTcpClient()
  Start-Job -ArgumentList $client, $TargetAddress, $TargetPort -ScriptBlock {
    param($client, $TargetAddress, $TargetPort)
    try {
      $target = [System.Net.Sockets.TcpClient]::new()
      $target.Connect($TargetAddress, $TargetPort)
      $cs = $client.GetStream()
      $ts = $target.GetStream()
      $a = $cs.CopyToAsync($ts)
      $b = $ts.CopyToAsync($cs)
      [System.Threading.Tasks.Task]::WaitAny($a, $b) | Out-Null
    } catch {
    } finally {
      try { $client.Close() } catch {}
      try { $target.Close() } catch {}
    }
  } | Out-Null
}
