import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/post_comment_service/api_post_comment_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/custom_text_form_field.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({super.key, required this.postId}
    );
  final String postId;

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  //final TextEditingController _replyController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];
  int? _editingIndex;
  //int? _replyingToIndex;
  final ScrollController _scrollController = ScrollController();
  int currentPage = 0; // Current page for pagination
  String currentUsername = '';
  bool isLoading = true;
  final int pageSize = 10; // Number of Blogs per page
  List<dynamic> blogs = [];
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments({bool isLoadMore = false}) async {
    try {
      Map<String, dynamic>? result;
      result = await ApiPostCommentService.getComments(
        widget.postId,
        currentPage,
        pageSize,
      );
      if (result != null && result['statusCode'] == 200) {
        final List<dynamic> newBlogs =
            List<Map<String, dynamic>>.from(json.decode(result['body']));
        setState(() {
          if (isLoadMore) {
            blogs.addAll(newBlogs);
            isLoadingMore = false;
          } else {
            blogs = newBlogs;
            isLoading = false;
          }
        });
        // if (newBlogs.length < pageSize) {
        //   _scrollController.removeListener(_onScroll); // No more blogs to load
        // }
      } else {
        CustomSnackbar.showSnackBar(context, result?['body'], false);
        return;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _addComment(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _comments.add({
        'text': text,
        'isSent': false,
        'date': DateTime.now(),
      });
    });

    _commentController.clear();

    // Scroll to the bottom when a new comment is added
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  // void _addReply(int commentIndex, String replyText) {
  //   if (replyText.trim().isEmpty) return;

  //   setState(() {
  //     _comments[commentIndex]['replies'].add({
  //       'text': replyText,
  //       'isSent': true,
  //       'date': DateTime.now(),
  //     });
  //   });

  //   _replyController.clear();
  //   setState(() {
  //     _replyingToIndex = null;
  //   });
  // }

  void _editOrUpdateComment(int index) {
    if (_editingIndex == index) {
      // Update comment and exit edit mode
      setState(() {
        _comments[index]['text'] = _commentController.text;
        _editingIndex = null;
        _commentController.clear();
      });
    } else {
      // Enter edit mode
      setState(() {
        _editingIndex = index;
        _commentController.text = _comments[index]['text'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                final isEditing = _editingIndex == index;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: comment['isSent']
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: comment['isSent']
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!comment['isSent'])
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: const Text(
                                  'A', // Placeholder for sender avatar
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: comment['isSent']
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (isEditing)
                                    CustomTextFormField(
                                      controller: _commentController,
                                      labelText: 'Edit comment...',
                                      keyboardType: TextInputType.multiline,
                                      showCounter: false,
                                      readOnly: false,
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: null,
                                        border: Border.all(
                                          color: comment['isSent']
                                              ? AppColors.primaryColor
                                              : Colors.black, // Outline color
                                          width:
                                              1.0, // Thickness of the outline
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(12),
                                          topRight: const Radius.circular(12),
                                          bottomLeft: comment['isSent']
                                              ? const Radius.circular(12)
                                              : const Radius.circular(0),
                                          bottomRight: comment['isSent']
                                              ? const Radius.circular(0)
                                              : const Radius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        comment['text'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${comment['date'].hour}:${comment['date'].minute.toString().padLeft(2, '0')} on ${comment['date'].day}/${comment['date'].month}/${comment['date'].year}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (comment['isSent'])
                              Container(
                                decoration: BoxDecoration(
                                  color: isEditing
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _editOrUpdateComment(index);
                                  },
                                  icon: Icon(
                                    isEditing ? Icons.check : Icons.edit,
                                    color:
                                        isEditing ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Reply Button
                    // if (_replyingToIndex == null)
                    //   TextButton(
                    //     onPressed: () {
                    //       setState(() {
                    //         _replyingToIndex = index;
                    //       });
                    //     },
                    //     child: const Text('Reply',
                    //     style: TextStyle(color: AppColors.primaryColor),),
                    //   ),
                    // // Display replies
                    // if (comment['replies'].isNotEmpty)
                    //   ...comment['replies'].map<Widget>((reply) {
                    //     return Align(
                    //       alignment: Alignment.centerLeft,
                    //       child: Container(
                    //         margin: const EdgeInsets.symmetric(
                    //             vertical: 4.0, horizontal: 32.0),
                    //         child: Row(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             CircleAvatar(
                    //               backgroundColor: Colors.grey[300],
                    //               child: const Text('A'),
                    //             ),
                    //             const SizedBox(width: 8),
                    //             Expanded(
                    //               child: Container(
                    //                 padding: const EdgeInsets.all(12),
                    //                 decoration: BoxDecoration(
                    //                   color: null,
                    //                   border: Border.all(
                    //                     color: Colors.black,
                    //                     width: 1.0,
                    //                   ),
                    //                   borderRadius: const BorderRadius.all(
                    //                     Radius.circular(12),
                    //                   ),
                    //                 ),
                    //                 child: Text(
                    //                   reply['text'],
                    //                   style: const TextStyle(fontSize: 16),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     );
                    //   }).toList(),
                    // if (_replyingToIndex == index)
                    //   Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Row(
                    //       children: [
                    //         Expanded(
                    //           child: CustomTextFormField(
                    //             controller: _replyController,
                    //             labelText: 'Type your reply...',
                    //             keyboardType: TextInputType.multiline,
                    //             showCounter: false,
                    //             readOnly: false,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 8),
                    //         IconButton(
                    //           onPressed: () {
                    //             _addReply(index, _replyController.text);
                    //           },
                    //           icon: const Icon(Icons.send, size: 20),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _commentController,
                    labelText: 'Type your comment...',
                    keyboardType: TextInputType.multiline,
                    readOnly: false,
                    showCounter: false,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (_editingIndex != null) {
                      _editOrUpdateComment(_editingIndex!);
                    } else {
                      _addComment(_commentController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textColor,
                  ),
                  icon: const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
