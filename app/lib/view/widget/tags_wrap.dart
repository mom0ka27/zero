import 'package:flutter/material.dart';

class TagsWrap extends StatelessWidget {
  final List<String> tags;
  const TagsWrap(this.tags, {super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      clipBehavior: Clip.antiAlias,
      children:
          tags
              .map(
                (e) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                  margin: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(e, style: Theme.of(context).textTheme.labelLarge),
                ),
              )
              .toList(),
    );
  }
}
