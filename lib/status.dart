import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

class StatusAccount {
  final String displayName;
  final String account;

  const StatusAccount({
    required this.displayName,
    required this.account,
  });

  factory StatusAccount.fromJson(Map<String, dynamic> json) {
    return StatusAccount(
      displayName: json['display_name'],
      account: json['acct'],
    );
  }
}

class StatusLink {
  final String title;
  final String description;

  const StatusLink({
    required this.title,
    required this.description,
  });

  factory StatusLink.fromJson(Map<String, dynamic> json) {
    return StatusLink(title: json['title'], description: json['description']);
  }
}

class Status {
  final String content;
  final StatusAccount account;
  final DateTime createdAt;
  final Status? reblog;
  final StatusLink? card;
  final String? imageUrl;

  const Status({
    required this.content,
    required this.account,
    required this.createdAt,
    this.reblog,
    this.card,
    this.imageUrl,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    Status? reblog;
    if (json['reblog'] != null) {
      reblog = Status.fromJson(json['reblog']);
    }

    StatusLink? card;
    if (json['card'] != null) {
      card = StatusLink.fromJson(json['card']);
    }

    String? imageUrl;
    if (json['media_attachments'] != null) {
      final attachments = json['media_attachments'] as List<dynamic>;
      if (attachments.isNotEmpty) {
        final firstAttachment = attachments[0] as Map<String, dynamic>;
        imageUrl = firstAttachment['url'];
      }
    }

    return Status(
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      account: StatusAccount.fromJson(json['account']),
      reblog: reblog,
      card: card,
      imageUrl: imageUrl,
    );
  }
}

class StatusList extends StatelessWidget {
  StatusList({Key? key, required this.data}) : super(key: key);

  final Iterable<Status> data;

  final dateFormat = DateFormat.yMd();
  final timeFormat = DateFormat.Hms();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: data.map((status) => StatusCard(
        status: status,
        dateFormat: dateFormat,
        timeFormat: timeFormat,
      )).toList(),
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({
    Key? key,
    required this.status,
    required this.dateFormat,
    required this.timeFormat,
  }) : super(key: key);

  final Status status;
  final DateFormat dateFormat;
  final DateFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    String contentStr = status.content;
    String subtitle = '${dateFormat.format(status.createdAt)} at ${timeFormat.format(status.createdAt)}';

    if (status.reblog != null) {
      final reblog = status.reblog!;
      contentStr = reblog.content;
      subtitle = 'reblogged from ${reblog.account.displayName} $subtitle';
    }

    ListTile? statusLinkCard;
    if (status.card != null) {
      statusLinkCard = ListTile(
        title: Text(status.card!.title),
        subtitle: Text(status.card!.description),
      );
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(status.account.displayName),
            subtitle: Text(subtitle),
          ),
          Html(data: contentStr),
          if (statusLinkCard != null) statusLinkCard,
          if (status.imageUrl != null) Image(image: NetworkImage(status.imageUrl!)),
        ],
      ),
    );
  }
}
