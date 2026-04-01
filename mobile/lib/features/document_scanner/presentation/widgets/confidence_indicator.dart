import 'package:flutter/material.dart';

class ConfidenceIndicator extends StatelessWidget {
	final String label;
	final double confidence;

	const ConfidenceIndicator({
		super.key,
		required this.label,
		required this.confidence,
	});

	@override
	Widget build(BuildContext context) {
		final clamped = confidence.clamp(0.0, 1.0).toDouble();
		final percentage = (clamped * 100).round();

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Row(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: [
						Text(label, style: Theme.of(context).textTheme.bodySmall),
						Text(
							'$percentage%',
							style: Theme.of(context).textTheme.bodySmall?.copyWith(
										fontWeight: FontWeight.w600,
										color: _colorFor(clamped),
									),
						),
					],
				),
				const SizedBox(height: 4),
				ClipRRect(
					borderRadius: BorderRadius.circular(99),
					child: LinearProgressIndicator(
						value: clamped,
						minHeight: 6,
						backgroundColor: Colors.grey.shade200,
						valueColor: AlwaysStoppedAnimation<Color>(_colorFor(clamped)),
					),
				),
			],
		);
	}

	Color _colorFor(double value) {
		if (value >= 0.8) return Colors.green;
		if (value >= 0.55) return Colors.orange;
		return Colors.red;
	}
}
