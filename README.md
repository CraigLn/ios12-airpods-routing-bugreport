# ios12-airpods-routing-bugreport
Test app for displaying/verifying issue with AirPods not allowing routing overrides

## Summary:
System will force the route back to AirPods if the application attempts use `overrideOutputAudioPort(_:)`

Sample app can be found [here](https://github.com/CraigLn/ios12-airpods-routing-bugreport.git)

## Steps to Reproduce:
1. Pair AirPods to device, and place in ears so device registers AirPods as connected.
  * Audio route will automatically switch to AirPods
2. Open Application
3. Setup `AVAudioSession` according to the configuration below
4. Configure a `NotificationCenter` observer to listen and report changes on `AVAudioSession.routeChangeNotification`
5. Activate the audio session by passing `true` to `setActive(_:)`
6. Pass `AVAudioSession.PortOverride.speaker` to `overrideOutputAudioPort(_:)` in order to initiate an audio route override
7. Observer the changes fired from your route change listener from step 4


## Expected Results:
App audio should be routed to the speakers instead of the AirPods.

## Actual Results:
`AVAudioSessionRouteChangeNotification` will report route changed due to `AVAudioSessionRouteChangeReasonOverride`, but then immediate after will switch back to AirPods with the reason `AVAudioSessionRouteChangeReasonNewDeviceAvailable`.  

> NOTE: At no point were the AirPods moved or removed.

## Version/Build:
* Able to reproduce building with Xcode 10.0 (10A255) using an iPhone 8+ running iOS 12.0.1 (16A404).
* Working as expected building with Xcode 10.0 (10A255) using an iPhone 7 running iOS 11.4.1 (15G77)

## Configuration:
* `AVAudioSession` category: `AVAudioSessionCategoryPlayAndRecord`
* `AVAudioSession` mode: `AVAudioSessionModeVoiceChat`
* `AVAudioSession` category options mode: `AVAudioSessionCategoryOptionAllowBluetooth`
