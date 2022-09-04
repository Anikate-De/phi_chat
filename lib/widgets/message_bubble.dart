import 'package:cached_network_image/cached_network_image.dart';
import 'package:phi_chat/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final Function replyCallback;

  const MessageBubble(
      {required this.message, required this.replyCallback, Key? key})
      : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final emojiRegex = RegExp(
    r'[\u{1f300}-\u{1f5ff}\u{1f900}-\u{1f9ff}\u{1f600}-\u{1f64f}'
    r'\u{1f680}-\u{1f6ff}\u{2600}-\u{26ff}\u{2700}'
    r'-\u{27bf}\u{1f1e6}-\u{1f1ff}\u{1f191}-\u{1f251}'
    r'\u{1f004}\u{1f0cf}\u{1f170}-\u{1f171}\u{1f17e}'
    r'-\u{1f17f}\u{1f18e}\u{3030}\u{2b50}\u{2b55}'
    r'\u{2934}-\u{2935}\u{2b05}-\u{2b07}\u{2b1b}'
    r'-\u{2b1c}\u{3297}\u{3299}\u{303d}\u{00a9}'
    r'\u{00ae}\u{2122}\u{23f3}\u{24c2}\u{23e9}'
    r'-\u{23ef}\u{25b6}\u{23f8}-\u{23fa}\u{200d}]+',
    unicode: true,
  );

  bool hasOnlyEmojis(String text, {bool ignoreWhitespace = false}) {
    if (ignoreWhitespace) text = text.replaceAll(' ', '');
    for (final c in Characters(text)) {
      if (!emojiRegex.hasMatch(c)) return false;
    }
    return true;
  }

  Offset _position = Offset.zero;
  bool _animateBack = false;

  void startPosition(DragStartDetails details) {
    setState(() {
      _animateBack = false;
    });
  }

  void updatePosition(DragUpdateDetails details) {
    if (_position.dx >= 0 && _position.dx <= 85) {
      setState(() {
        _position += details.delta;
      });
    }
    if (_position.dx > 85) setState(() => _position = const Offset(85, 0));
    if (_position.dx < 0) setState(() => _position = Offset.zero);
  }

  void endPosition(DragEndDetails details) {
    if (_position.dx > 70) {
      widget.replyCallback(
          text: widget.message.text ?? '', sender: widget.message.sender);
    }
    setState(() {
      _position = Offset.zero;
      _animateBack = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: updatePosition,
      onHorizontalDragStart: startPosition,
      onHorizontalDragEnd: endPosition,
      child: Builder(
        builder: (context) {
          int millisecs = _animateBack ? 300 : 0;

          return AnimatedContainer(
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: millisecs),
            transform: Matrix4.identity()
              ..translate(_position.dx, _position.dy),
            child: IntrinsicHeight(
              child: Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(-85, 0),
                    child: Container(
                      margin: EdgeInsets.only(
                        top: widget.message.showSender
                            ? hasOnlyEmojis(widget.message.text ?? '')
                                ? 0
                                : 17
                            : 0,
                        left: 24,
                      ),
                      width: 85,
                      height: double.infinity,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.reply,
                          size: 28,
                          color: Colors.blue.shade300,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      widget.message.isOnNewDate
                          ? DateBubble(date: widget.message.newDate)
                          : Container(),
                      Stack(children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                              top: widget.message.showSender ? 6 : 0,
                              bottom: 3,
                              left: widget.message.isCurrentUser ? 60 : 18,
                              right: widget.message.isCurrentUser ? 18 : 60),
                          child: Column(
                            crossAxisAlignment: widget.message.isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              widget.message.showSender
                                  ? SenderText(
                                      sender: widget.message.isCurrentUser
                                          ? ''
                                          : widget.message.sender)
                                  : Container(),
                              (widget.message.text != null &&
                                          !hasOnlyEmojis(
                                              widget.message.text!)) ||
                                      widget.message.isMedia
                                  ? Container(
                                      padding: widget.message.isMedia
                                          ? const EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 6)
                                          : !widget.message.isReplying
                                              ? const EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 20)
                                              : const EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: widget.message.isCurrentUser
                                                ? 0
                                                : 0.6,
                                            color: Colors.black12),
                                        color: widget.message.isCurrentUser
                                            ? Colors.blue
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.only(
                                            topLeft:
                                                widget.message.isCurrentUser
                                                    ? const Radius.circular(25)
                                                    : const Radius.circular(3),
                                            topRight:
                                                widget.message.isCurrentUser
                                                    ? const Radius.circular(3)
                                                    : const Radius.circular(25),
                                            bottomLeft: widget
                                                    .message.isCurrentUser
                                                ? const Radius.circular(25)
                                                : widget.message.isClosing
                                                    ? const Radius.circular(25)
                                                    : const Radius.circular(3),
                                            bottomRight: widget
                                                    .message.isCurrentUser
                                                ? widget.message.isClosing
                                                    ? const Radius.circular(25)
                                                    : const Radius.circular(3)
                                                : const Radius.circular(25)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              widget.message.isReplying
                                                  ? Container(
                                                      width: double.infinity,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 8),
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 12,
                                                          horizontal: 16),
                                                      decoration: BoxDecoration(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                const Radius
                                                                    .circular(20),
                                                            bottomRight:
                                                                const Radius
                                                                    .circular(20),
                                                            topLeft: widget
                                                                    .message
                                                                    .isCurrentUser
                                                                ? const Radius
                                                                        .circular(
                                                                    20)
                                                                : const Radius
                                                                    .circular(3),
                                                            topRight: !widget
                                                                    .message
                                                                    .isCurrentUser
                                                                ? const Radius
                                                                        .circular(
                                                                    20)
                                                                : const Radius
                                                                    .circular(3),
                                                          )),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  widget.message
                                                                      .replySender!,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Handlee',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    letterSpacing:
                                                                        1.2,
                                                                    color: widget
                                                                            .message
                                                                            .isCurrentUser
                                                                        ? Colors
                                                                            .white
                                                                            .withOpacity(
                                                                                0.85)
                                                                        : Colors
                                                                            .black
                                                                            .withOpacity(0.85),
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 4),
                                                                Text(
                                                                  widget
                                                                          .message
                                                                          .replyText!
                                                                          .isEmpty
                                                                      ? 'Media'
                                                                      : widget
                                                                          .message
                                                                          .replyText!,
                                                                  maxLines: 2,
                                                                  softWrap:
                                                                      false,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Handlee',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    letterSpacing:
                                                                        0.9,
                                                                    color: widget
                                                                            .message
                                                                            .isCurrentUser
                                                                        ? Colors
                                                                            .white60
                                                                        : Colors
                                                                            .grey
                                                                            .shade700,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                              widget.message.isMedia &&
                                                      widget.message.mediaURL !=
                                                          null
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft: widget
                                                                  .message
                                                                  .isCurrentUser
                                                              ? const Radius
                                                                  .circular(20)
                                                              : Radius.zero,
                                                          topRight: !widget
                                                                  .message
                                                                  .isCurrentUser
                                                              ? const Radius
                                                                  .circular(20)
                                                              : Radius.zero,
                                                        ),
                                                        child:
                                                            CachedNetworkImage(
                                                                imageUrl: widget
                                                                    .message
                                                                    .mediaURL!),
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                              widget.message.text!.isNotEmpty
                                                  ? Padding(
                                                      padding: widget
                                                              .message.isMedia
                                                          ? const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: 14)
                                                          : widget.message
                                                                  .isReplying
                                                              ? const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16)
                                                              : EdgeInsets.zero,
                                                      child: Text(
                                                        widget.message.text ??
                                                            'Unavailable',
                                                        style: TextStyle(
                                                          fontFamily: 'Handlee',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 1.2,
                                                          color: widget.message
                                                                  .isCurrentUser
                                                              ? Colors.white
                                                              : Colors.black,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: widget.message.isMedia
                                                ? const EdgeInsets.only(
                                                    bottom: 8, right: 12)
                                                : widget.message.isReplying
                                                    ? const EdgeInsets.only(
                                                        bottom: 8, right: 16)
                                                    : EdgeInsets.zero,
                                            child: Text(
                                              '${widget.message.hour!.padLeft(2, '0')}:${widget.message.minute!.padLeft(2, '0')}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'Handlee',
                                                  fontWeight: FontWeight.bold,
                                                  color: widget
                                                          .message.isCurrentUser
                                                      ? Colors.blue[100]
                                                      : Colors.grey),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            widget.message.text!,
                                            style:
                                                const TextStyle(fontSize: 40),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '${widget.message.hour!.padLeft(2, '0')}:${widget.message.minute!.padLeft(2, '0')}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Handlee',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          )
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        widget.message.showSender
                            ? Positioned(
                                top: widget.message.text != null &&
                                        hasOnlyEmojis(widget.message.text!)
                                    ? 6
                                    : widget.message.isCurrentUser
                                        ? 5.4
                                        : 11,
                                left: widget.message.isCurrentUser ? null : 3.6,
                                right:
                                    widget.message.isCurrentUser ? 3.6 : null,
                                child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 3.2)),
                                    child: widget.message.pfp != null &&
                                            widget.message.pfp!.isNotEmpty
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                            imageUrl: widget.message.pfp!,
                                            fit: BoxFit.cover,
                                            maxHeightDiskCache: 32,
                                            placeholder: (context, url) {
                                              return Icon(
                                                Icons.person_rounded,
                                                color: Colors.grey.shade200,
                                                size: 16,
                                              );
                                            },
                                            errorWidget: (context, url, error) {
                                              return Icon(
                                                Icons.person_rounded,
                                                color: Colors.grey.shade200,
                                                size: 16,
                                              );
                                            },
                                          ))
                                        : Icon(
                                            Icons.person_rounded,
                                            color: Colors.grey.shade200,
                                            size: 16,
                                          )))
                            : const SizedBox.shrink()
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SenderText extends StatelessWidget {
  final String sender;
  const SenderText({required this.sender, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          SizedBox(
            height: sender.isEmpty ? 0 : 8,
          ),
          Text(
            sender,
            style: TextStyle(
              fontFamily: 'Handlee',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 10,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(
            height: sender.isEmpty ? 0 : 3,
          ),
        ],
      ),
    );
  }
}

class DateBubble extends StatelessWidget {
  final DateTime date;

  const DateBubble({required this.date, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 16, bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            width: 1,
            color: Colors.blue,
          ),
        ),
        child: Text(
          DateFormat.yMMMd().format(date),
          style: const TextStyle(
              fontFamily: 'Handlee',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              wordSpacing: 2,
              fontSize: 14,
              color: Colors.blue),
        ),
      ),
    );
  }
}
