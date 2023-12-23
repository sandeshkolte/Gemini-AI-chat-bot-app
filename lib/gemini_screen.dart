import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';

class GeminiScreen extends StatefulWidget {
  const GeminiScreen({super.key});

  @override
  State<GeminiScreen> createState() => _MyAppState();
}

class _MyAppState extends State<GeminiScreen> {
  // final String url =
  //     "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyAG-lc64EjUwpynyWpO_6cjW3Gdrp_w8bE"; // replace with your API endpoint

  final chatController = TextEditingController();
  List<String> messages = [];
  bool isSendbyMe = false;
  bool is_Typing = false;

  Future<void> callGemini(String prompt) async {
    const apiKey = "AIzaSyAG-lc64EjUwpynyWpO_6cjW3Gdrp_w8bE";
    const apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey";

    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Perform null checks to avoid accessing null values
        if (jsonResponse.containsKey("candidates") &&
            jsonResponse["candidates"] != null &&
            jsonResponse["candidates"].isNotEmpty &&
            jsonResponse["candidates"][0].containsKey("content") &&
            jsonResponse["candidates"][0]["content"] != null &&
            jsonResponse["candidates"][0]["content"].containsKey("parts") &&
            jsonResponse["candidates"][0]["content"]["parts"] != null &&
            jsonResponse["candidates"][0]["content"]["parts"].isNotEmpty &&
            jsonResponse["candidates"][0]["content"]["parts"][0]
                .containsKey("text")) {
          final result =
              jsonResponse["candidates"][0]["content"]["parts"][0]["text"];
          debugPrint(result);
          setState(() {
            messages.add(result);
            isSendbyMe = false;
          });
        } else {
          debugPrint("Invalid JSON structure or empty data");
        }
      } else {
        debugPrint("Failed to call Gemini: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      appBar: AppBar(
          //The AppBar
          centerTitle: true,
          elevation: 2,
          backgroundColor: const Color(0x9923395d),
          title: Text(
            "Gemini A.I.",
            style: GoogleFonts.nunito(color: Colors.white),
          )
          //  Image.asset(
          //   "assets/images/gemini_logo.jpeg",
          // )
          ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                //The messages area
                itemCount: messages.length,
                reverse: false,
                itemBuilder: (context, index) {
                  final isSentByUser = index % 2 == 0;

                  return MessageTile(
                      message: messages[index], isSentByUser: isSentByUser);
                },
              ),
            ),
            if (is_Typing) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            context.isLargeSize
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      //The Textfield area for Web
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0x991f2531),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: 700,
                          child: TextField(
                            keyboardAppearance: Brightness.dark,
                            controller: chatController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.only(left: 20),
                              hintText: "Ask me Anything",
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () async {
                            try {
                              setState(() {
                                is_Typing = true;
                              });
                              messages.add(chatController.text);
                              await callGemini(chatController.text);
                              chatController.clear();
                            } catch (e) {
                              debugPrint(e.toString());
                            } finally {
                              setState(() {
                                is_Typing = false;
                              });
                            }
                          },
                          child: Container(
                            //The arrow button for send
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(45),
                              color: const Color.fromARGB(255, 128, 128, 255),
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    //The Textfield area for Mobile
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0x991f2531),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: 300,
                          child: TextField(
                            keyboardAppearance: Brightness.dark,
                            controller: chatController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.only(left: 20),
                              hintText: "Ask me Anything",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () async {
                          try {
                            setState(() {
                              is_Typing = true;
                            });
                            messages.add(chatController.text);
                            await callGemini(chatController.text);
                            chatController.clear();
                          } catch (e) {
                            debugPrint(e.toString());
                          } finally {
                            setState(() {
                              is_Typing = false;
                            });
                          }
                        },
                        child: Container(
                          //The arrow button for send
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(45),
                            color: const Color.fromARGB(255, 128, 128, 255),
                          ),
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  const MessageTile({
    Key? key,
    required this.message,
    this.color,
    required this.isSentByUser,
  }) : super(key: key);

  final String message;
  final Color? color;

  final bool isSentByUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: context.isLargeSize ? 1100 : MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isSentByUser
              ? const Color.fromARGB(255, 30, 30, 30)
              : const Color(0x99343d52),
        ),
        child: Row(
          children: [
            isSentByUser
                ? const Icon(
                    Icons.person_outline_rounded,
                  )
                : const Icon(
                    Icons.g_mobiledata,
                    size: 25,
                  ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                SizedBox(
                    width: context.isLargeSize ? 1000 : 313,
                    child: SelectableText(message,
                        style: GoogleFonts.nunito(
                            fontSize: 17, color: Colors.white))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
