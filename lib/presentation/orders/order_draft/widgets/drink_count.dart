import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milkshake/presentation/orders/order_draft/order_draft_bloc.dart';
import 'package:milkshake/presentation/shared/widgets/app_text_field.dart';

class DrinkCountInput extends StatefulWidget {
  const DrinkCountInput();

  @override
  State<DrinkCountInput> createState() => _DrinkCountInputState();
}

class _DrinkCountInputState extends State<DrinkCountInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _error = null);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDraftBloc, OrderDraftState>(
      buildWhen: (p, n) => p.drinkCount != n.drinkCount || p.config != n.config,
      builder: (context, state) {
        final max = state.config?.maxDrinks.value ?? 10;

        if (!_focusNode.hasFocus) {
          final desired = state.drinkCount.toString();
          if (_controller.text != desired) _controller.text = desired;
        }

        return AppTextField(
          label: 'Number of Milkshakes Required?',
          hintText: 'Insert number',
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          errorText: _error,
          onChanged: (v) {
            final parsed = int.tryParse(v);
            if (parsed == null) {
              setState(() => _error = 'Numeric value only');
              return;
            }
            if (parsed < 1) {
              setState(() => _error = 'Minimum is 1');
              return;
            }
            if (parsed > max) {
              setState(() => _error = 'Maximum is $max');
              return;
            }
            setState(() => _error = null);
            context.read<OrderDraftBloc>().add(OrderDraftDrinkCountChanged(parsed));
          },
        );
      },
    );
  }
}
