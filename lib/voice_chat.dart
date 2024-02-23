import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';

String listenerId = DateTime.now().millisecondsSinceEpoch.toString();

// ignore: must_be_immutable
class VoicChat extends StatefulWidget {
  VoicChat(
      {super.key,
      this.uid = 'SUPERHERO1',
      this.isPresenter = false,
      this.sessionId = '123',
      this.isUIkit = true});

  String uid;
  String sessionId;
  bool isPresenter;
  bool isUIkit;

  @override
  State<VoicChat> createState() => _VoicChatState();
}

class _VoicChatState extends State<VoicChat>
    implements CometChatCallsEventsListener {
  String region = "IN";
  String appId = "25311743d3a92286";
  String authKey = "5236f31f077d3b65e03a24b92c1f318269ee5a4e";
  late CallAppSettings callAppSettings;
  late AppSettings appSettings;
  String? callToken;

  Widget? voiceWidget;

  // Dyncamic Value

  late String uid;
  late String sessionId;
  late bool isPresenter;

  @override
  void initState() {
    isPresenter = widget.isPresenter;
    sessionId = widget.sessionId;
    uid = widget.uid;
    _initAppSeting();
    _initCometChat();
    super.initState();
    CometChatCalls.addCallsEventListeners(listenerId, this);
  }

  @override
  void dispose() {
    super.dispose();
    CometChatCalls.removeCallsEventListeners(listenerId);
  }

  void muteMic() {
    CometChatCalls.muteAudio(true, onSuccess: (success) {
      debugPrint("CometV Mute Success $success");
    }, onError: (error) {
      debugPrint("CometV Error $error");
    });
  }

  void endCall() {
    CometChatCalls.endSession(onSuccess: (success) {
      debugPrint("CometV End Success");
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }, onError: (error) {
      debugPrint("CometV Error End Session: $error");
    });
  }

  void unMuteMic() {
    CometChatCalls.muteAudio(false, onSuccess: (success) {
      debugPrint("CometV Unmute Success $success");
    }, onError: (error) {
      debugPrint("CometV Error Unmute $error");
    });
  }

  void startSession() {
    CometChatCalls.setAudioMode("SPEAKER", onSuccess: (success) {
      debugPrint("Success $success");
    }, onError: (err) {
      debugPrint("Error $err");
    });

    CometChatCalls.muteAudio(false, onSuccess: (success) {
      debugPrint("CometV Unmute Success $success");
    }, onError: (error) {
      debugPrint("CometV Error Unmute $error");
    });
  }

  Widget ownKit() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Room Id : $sessionId",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "User Id : $uid",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  muteMic();
                },
                icon: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
              IconButton(
                onPressed: () {
                  endCall();
                },
                icon: const Icon(
                  Icons.call_end,
                  color: Colors.red,
                  size: 30.0,
                ),
              ),
              IconButton(
                onPressed: () {
                  unMuteMic();
                },
                icon: const Icon(
                  Icons.mic_off_rounded,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget uiKit() {
    return SafeArea(
      child: voiceWidget ??
          const CircularProgressIndicator(
            color: Colors.white,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF333333),
        body: widget.isUIkit ? uiKit() : ownKit());
  }

  void _initAppSeting() {
    callAppSettings = (CallAppSettingBuilder()
          ..appId = appId
          ..region = region)
        .build();

    appSettings = (AppSettingsBuilder()
          ..subscriptionType = CometChatSubscriptionType.allUsers
          ..region = region
          ..autoEstablishSocketConnection = true)
        .build();
  }

  void _initCometChat() async {
    try {
      await CometChat.init(appId, appSettings, onSuccess: (String success) {
        debugPrint(
            "CometV  Info Initialization completed successfully  $success");
      }, onError: (CometChatException exeception) {
        debugPrint(
            "CometV  Error Initialization failed with exception: ${exeception.message}");
        throw 'Error Init Comet';
      });
      _initCometCall();
    } catch (e) {
      debugPrint(
          "CometV  Error Comet Chat Initialization failed with exception: ${e.toString()}");
    }
  }

  void _initCometCall() async {
    try {
      CometChatCalls.init(callAppSettings, onSuccess: (String successMessage) {
        debugPrint(
            "CometV Info Initialization completed successfully  $successMessage");
      }, onError: (CometChatCallsException e) {
        debugPrint(
            "CometV Error Initialization failed with exception: ${e.message}");
        throw 'Error Init Comet Call';
      });
      _loginCometUser();
    } catch (e) {
      debugPrint(
          "CometV Chat Calls Initialization failed with exception: ${e.toString()}");
    }
  }

  void _loginCometUser() async {
    try {
      await CometChat.logout(onSuccess: (suc) {}, onError: (error) {});

      final user = await CometChat.getLoggedInUser();
      if (user == null) {
        User? iuser =
            await CometChat.login(uid, authKey, onSuccess: (User user) {
          debugPrint("CometV Login Successful : $user");
        }, onError: (CometChatException e) {
          debugPrint("CometV Error Login failed with exception:  ${e.message}");
          throw 'Error Init Comet Login Call';
        });
        debugPrint("CometV User Name ${iuser?.name}");
      }
      debugPrint("CometV User Name ${user?.name}");
      generateCallToken();
    } catch (e) {
      throw 'CometV Error Log in Comet';
    }
  }

  void generateCallToken() async {
    try {
      String? userAuthToken = await CometChat.getUserAuthToken();
      if (userAuthToken == null) {
        debugPrint("CometV  Couldn't get Auth Token");
        return null;
      }
      CometChatCalls.generateToken(sessionId, userAuthToken,
          onSuccess: (GenerateToken generateToken) {
        debugPrint("CometV  Generate Token success: ${generateToken.token}");
        callToken = generateToken.token;
        _initPresentationSettings();
      }, onError: (CometChatCallsException e) {
        debugPrint("CometV  Error Generate Token Error: $e");
        throw 'CometV  Error Generate Comet Call Token';
      });
    } catch (e) {
      debugPrint("CometV Error Generate Token Error: $e");
    }
  }

  void _initPresentationSettings() {
    PresentationSettings presentationSettings = (PresentationSettingsBuilder()
          ..enableDefaultLayout = widget.isUIkit
          ..isPresenter = isPresenter
          ..setAudioOnlyCall = true
          ..listener = this)
        .build();

    _initCall(presentationSettings);
  }

  void _initCall(PresentationSettings presentationSettings) async {
    try {
      CometChatCalls.joinPresentation(callToken!, presentationSettings,
          onSuccess: (Widget? callingWidget) {
        if (widget.isUIkit) {
          setState(() {
            voiceWidget = callingWidget;
          });
        } else {
          startSession();
        }
        debugPrint("CometV Presentation Success");
      }, onError: (CometChatCallsException e) {
        debugPrint("CometV  Error: $e");
        throw "Error in Joining Presentation";
      });
    } catch (e) {
      debugPrint("CometV  Error in Joining Group Chat ${e.toString()}");
    }
  }

  @override
  void onAudioModeChanged(List<AudioMode> devices) {
    debugPrint("CometV onAudioModeChanged: ${devices.length}");
  }

  @override
  void onCallEndButtonPressed() {
    debugPrint("CometV onCallEndButtonPressed");
  }

  @override
  void onCallEnded() {
    debugPrint("CometV onCallEnded");
  }

  @override
  void onCallSwitchedToVideo(CallSwitchRequestInfo info) {
    debugPrint("CometV onCallSwitchedToVideo: ${info.requestAcceptedBy}");
  }

  @override
  void onRecordingToggled(RTCRecordingInfo info) {
    debugPrint("CometV onRecordingToggled: ${info.user?.name}");
  }

  @override
  void onUserListChanged(List<RTCUser> users) {
    debugPrint("CometV onUserListChanged: ${users.length}");
  }

  @override
  void onUserMuted(RTCMutedUser muteObj) {
    debugPrint("CometV onUserMuted: ${muteObj.mutedBy}");
  }

  @override
  void onUserJoined(RTCUser user) {
    debugPrint("CometV  onUserJoined: ${user.name}");
  }

  @override
  void onUserLeft(RTCUser user) {
    debugPrint("CometV  onUserLeft: ${user.name}");
  }

  // Error in Establishing Call
  @override
  void onError(CometChatCallsException ce) {
    debugPrint("CometV  Error onError: ${ce.message}");
  }
}
