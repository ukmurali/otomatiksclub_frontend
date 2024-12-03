import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/post_comment_service/api_post_comment_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/custom_text_form_field.dart';
import 'package:otomatiksclub/widgets/no_internet_view.dart';

class CommentPage extends StatefulWidget {
  const CommentPage(
      {super.key, required this.postId, required this.currentUsername});
  final String postId;
  final String currentUsername;

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _editCommentController = TextEditingController();
  //final TextEditingController _replyController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  int? _editingIndex;
  //int? _replyingToIndex;
  final ScrollController _scrollController = ScrollController();
  int currentPage = 0; // Current page for pagination
  bool isLoading = true;
  final int pageSize = 10; // Number of Blogs per page
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
        final List<dynamic> newComments =
            List<Map<String, dynamic>>.from(json.decode(result['body']));
        setState(() {
          _comments = [];
          for (var comment in newComments) {
            _comments.add({
              'commentId': comment['commentId'],
              'commentedBy': comment['commentedBy'],
              'text': comment['comment'],
              'isSent': comment['commentedBy'] == widget.currentUsername
                  ? true
                  : false,
              'date': comment['updatedAt'],
            });
          }
          if (isLoadMore) {
            isLoadingMore = false;
          } else {
            isLoading = false;
          }
        });
        // if (newBlogs.length < pageSize) {
        //   _scrollController.removeListener(_onScroll); // No more blogs to load
        // }
      } else {
        if (result?['body'] == 'Exception: No internet connection available') {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoInternetPage(),
              ),
            );
          }
        } else {
          CustomSnackbar.showSnackBar(context, result?['body'], false);
        }
        return;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _addComment(String text) async {
    if (text.trim().isEmpty) return;

    Map<String, dynamic> formData = {
      'comment': text,
      'postId': widget.postId,
    };

    Map<String, dynamic>? result =
        await ApiPostCommentService.createComment(formData);
    if (result['statusCode'] == 201) {
      _fetchComments();
    }
    else{
       if (result['body'] == 'Exception: No internet connection available') {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoInternetPage(),
              ),
            );
          }
        }
    }
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

  void _editOrUpdateComment(int index) async {
    String comment = _comments[index]['text'];
    if (_editingIndex == index) {
      // Update comment and exit edit mode
      setState(() {
        comment = _editCommentController.text;
        _editingIndex = null;
        _editCommentController.clear();
      });
    } else {
      // Enter edit mode
      setState(() {
        _editingIndex = index;
        _editCommentController.text = comment;
      });
    }
    Map<String, dynamic>? result = await ApiPostCommentService.updateComment(
        _comments[index]['commentId'], comment);
    if (result['statusCode'] == 200) {
      _fetchComments();
    }
    else{
       if (result['body'] == 'Exception: No internet connection available') {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoInternetPage(),
              ),
            );
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pass the updated comment count back
            Navigator.pop(context, _comments.length);
          },
        ),
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
                                child: Text(
                                  getInitials(comment[
                                      'commentedBy']), // Placeholder for sender avatar
                                  style: const TextStyle(
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
                                      controller: _editCommentController,
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
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${comment['date']}",
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Cancel icon (only visible in edit mode)
                                  if (isEditing)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _editingIndex =
                                                null; // Exit edit mode
                                            _editCommentController.clear();
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(
                                      width: 8), // Space between icons
                                  // Edit/Check icon
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
                                        color: isEditing
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
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
                    _addComment(_commentController.text);
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
