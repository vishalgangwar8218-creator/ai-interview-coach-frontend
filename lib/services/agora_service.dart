import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {

  static const String appId = "627867a5d40545428e4c2e6155295444";
  static const String channelName = "ai_interview_channel";
  static const String token = "";

  late RtcEngine agoraEngine;
  bool isInitialized = false;

  Future<void> initAgora() async {
    await [Permission.microphone].request();

    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await agoraEngine.enableAudio();
    await agoraEngine.setEnableSpeakerphone(true);
    isInitialized = true;
  }

  Future<void> joinChannel() async {
    if (!isInitialized) await initAgora();

    await agoraEngine.joinChannel(
        token: token,
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
        ),
    );
  }

  Future<void> muteMicrophone(bool mute) async {
    if (isInitialized) {
      await agoraEngine.muteLocalAudioStream(mute);
    }
  }

  Future<void> leaveChannel() async {
    if (isInitialized) {
      await agoraEngine.leaveChannel();
      await agoraEngine.release();
      isInitialized = false;
    }
  }
}