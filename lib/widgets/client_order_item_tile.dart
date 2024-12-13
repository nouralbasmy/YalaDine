import 'package:flutter/material.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientOrderItemTile extends StatefulWidget {
  final String imageUrl;
  final String title;
  final int quantity;
  final String specialRequest;
  final Function(int) onQuantityChanged;
  final Function(String) onSpecialRequestChanged;
  final Function() onDelete;

  const ClientOrderItemTile({
    required this.imageUrl,
    required this.title,
    required this.quantity,
    required this.specialRequest,
    required this.onQuantityChanged,
    required this.onSpecialRequestChanged,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _ClientOrderItemTileState createState() => _ClientOrderItemTileState();
}

class _ClientOrderItemTileState extends State<ClientOrderItemTile> {
  late bool isEditing;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    isEditing = false;
    _controller = TextEditingController(text: widget.specialRequest);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.title),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        widget.onDelete();
      },
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: ListTile(
          tileColor: Colors.white,
          leading: SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Special Request
              isEditing
                  ? TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: "Enter special instructions",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (value) {
                        setState(() => isEditing = false);
                        widget.onSpecialRequestChanged(value);
                      },
                    )
                  : GestureDetector(
                      onTap: () => setState(() => isEditing = true),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.specialRequest.isNotEmpty
                                  ? widget.specialRequest
                                  : "No special requests",
                              style: TextStyle(
                                fontSize: 13,
                                color: widget.specialRequest.isNotEmpty
                                    ? Colors.black
                                    : Colors.grey[500],
                                fontStyle: widget.specialRequest.isNotEmpty
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.edit,
                            color: Colors.grey[500],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 212, 148),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.quantity > 1) {
                      widget.onQuantityChanged(
                          widget.quantity - 1); // Decrease quantity
                    }
                  },
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.quantity.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    widget.onQuantityChanged(
                        widget.quantity + 1); // Increase quantity
                  },
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
