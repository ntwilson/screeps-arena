$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

npx spago bundle --module CaptureTheFlag.StandardStrategy

$contents = Get-Content -Raw .\index.js

$prefix = @"
import { prototypes, utils, constants } from 'game';

export function loop() {
"@

$suffix = "}"

$main = $prefix + "`n" + $contents + "`n" + $suffix

Set-Content -Path ~\ScreepsArena\beta-capture_the_flag\main.mjs -Value $main
