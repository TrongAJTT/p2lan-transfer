import 'package:flutter/material.dart';
import 'package:p2lan/utils/size_utils.dart';

/// Condition types for determining when to render two widgets in a row
sealed class TwoInARowConditionType {
  const TwoInARowConditionType();

  /// Threshold based on overall available width
  const factory TwoInARowConditionType.overallWidth(double value) =
      _OverallWidthCondition;

  /// Threshold based on first widget's preferred width
  const factory TwoInARowConditionType.widget1Width(double value) =
      _Width1WidgetCondition;

  /// Threshold based on second widget's preferred width
  const factory TwoInARowConditionType.widget2Width(double value) =
      _Width2WidgetCondition;

  /// Automatic wrapping - widgets will wrap based on available space
  const factory TwoInARowConditionType.auto() = _AutoCondition;
}

class _OverallWidthCondition extends TwoInARowConditionType {
  final double value;
  const _OverallWidthCondition(this.value);
}

class _Width1WidgetCondition extends TwoInARowConditionType {
  final double value;
  const _Width1WidgetCondition(this.value);
}

class _Width2WidgetCondition extends TwoInARowConditionType {
  final double value;
  const _Width2WidgetCondition(this.value);
}

class _AutoCondition extends TwoInARowConditionType {
  const _AutoCondition();
}

/// Group widget positioning for three-in-a-row layout
enum ThreeInARowGroupWidget {
  /// Group first two widgets on the left, third widget on the right
  leftMiddle,

  /// Group first widget on the left, last two widgets on the right
  middleRight,
}

/// Decorator for styling three widgets in a row layout
class ThreeInARowDecorator {
  final DynamicDimension? widthWidget1;
  final DynamicDimension? widthWidget2;
  final DynamicDimension? widthWidget3;
  final ThreeInARowGroupWidget groupWidget;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const ThreeInARowDecorator({
    this.widthWidget1,
    this.widthWidget2,
    this.widthWidget3,
    this.groupWidget = ThreeInARowGroupWidget.middleRight,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  ThreeInARowDecorator copyWith({
    DynamicDimension? widthWidget1,
    DynamicDimension? widthWidget2,
    DynamicDimension? widthWidget3,
    ThreeInARowGroupWidget? groupWidget,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisSize? mainAxisSize,
  }) {
    return ThreeInARowDecorator(
      widthWidget1: widthWidget1 ?? this.widthWidget1,
      widthWidget2: widthWidget2 ?? this.widthWidget2,
      widthWidget3: widthWidget3 ?? this.widthWidget3,
      groupWidget: groupWidget ?? this.groupWidget,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      mainAxisSize: mainAxisSize ?? this.mainAxisSize,
    );
  }
}

/// Decorator for styling two widgets in a row layout
class TwoInARowDecorator {
  final DynamicDimension? widthWidget1;
  final DynamicDimension? widthWidget2;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const TwoInARowDecorator({
    this.widthWidget1,
    this.widthWidget2,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  /// Factory method for equal flex layout (1:1 ratio)
  factory TwoInARowDecorator.flexEqual({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return TwoInARowDecorator(
      widthWidget1: DynamicDimension.expanded(),
      widthWidget2: DynamicDimension.expanded(),
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
    );
  }

  TwoInARowDecorator copyWith({
    DynamicDimension? widthWidget1,
    DynamicDimension? widthWidget2,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisSize? mainAxisSize,
  }) {
    return TwoInARowDecorator(
      widthWidget1: widthWidget1 ?? this.widthWidget1,
      widthWidget2: widthWidget2 ?? this.widthWidget2,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      mainAxisSize: mainAxisSize ?? this.mainAxisSize,
    );
  }
}

/// Helper class for measuring widget dimensions
class _WidgetMeasurer {
  final Widget widget;

  _WidgetMeasurer(this.widget);

  Size getSize(BoxConstraints constraints, BuildContext context) {
    try {
      // For most widgets, we'll estimate based on common patterns
      if (widget is Text) {
        final textWidget = widget as Text;
        final textPainter = TextPainter(
          text: TextSpan(
            text: textWidget.data ?? '',
            style: textWidget.style ?? Theme.of(context).textTheme.bodyMedium,
          ),
          textDirection: TextDirection.ltr,
          maxLines: textWidget.maxLines,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);
        return textPainter.size;
      }

      // For buttons and other common widgets, return reasonable estimates
      if (widget is ElevatedButton ||
          widget is OutlinedButton ||
          widget is TextButton) {
        return Size(constraints.maxWidth * 0.3, 48.0); // Standard button height
      }

      if (widget is TextField || widget is TextFormField) {
        return Size(
            constraints.maxWidth * 0.6, 56.0); // Standard text field height
      }

      // Default fallback
      return Size(constraints.maxWidth * 0.4, 48.0);
    } catch (e) {
      // Fallback size
      return Size(constraints.maxWidth * 0.4, 48.0);
    }
  }
}

/// Helper class for rendering widget layouts with threshold-based conditions
class WidgetLayoutRenderHelper {
  const WidgetLayoutRenderHelper._();

  /// Renders two widgets in a row if threshold condition is met, otherwise stacks them vertically
  static Widget twoInARowThreshold(
    Widget widget1,
    Widget widget2,
    TwoInARowDecorator decorator,
    TwoInARowConditionType conditionType, {
    TwoDimSpacing? spacing,
  }) {
    final defaultSpacing =
        spacing ?? TwoDimSpacing.specific(vertical: 8.0, horizontal: 8.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldRenderInRow = _shouldRenderInRow(
          constraints,
          widget1,
          widget2,
          decorator,
          conditionType,
          context,
          defaultSpacing,
        );

        if (shouldRenderInRow) {
          return _buildRowLayout(widget1, widget2, decorator, defaultSpacing);
        } else {
          return _buildColumnLayout(
              widget1, widget2, decorator, defaultSpacing);
        }
      },
    );
  }

  /// Renders three widgets in a row based on width thresholds
  static Widget threeInARowThreshold(
    Widget widget1,
    Widget widget2,
    Widget widget3, {
    required double threeInARowWidthThreshold,
    required ThreeInARowDecorator threeInARowDecorator,
    required double twoInARowWidthThreshold,
    required bool singleRowWidgetOnTop,
    required TwoInARowDecorator twoInARowDecorator,
    TwoDimSpacing? spacing,
  }) {
    final defaultSpacing =
        spacing ?? TwoDimSpacing.specific(vertical: 8.0, horizontal: 8.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        if (availableWidth >= threeInARowWidthThreshold) {
          // Render all three widgets in a single row
          return _buildThreeInRowLayout(
            widget1,
            widget2,
            widget3,
            threeInARowDecorator,
            defaultSpacing,
          );
        } else if (availableWidth >= twoInARowWidthThreshold) {
          // Render two rows: one with single widget, one with two widgets
          return _buildTwoRowLayout(
            widget1,
            widget2,
            widget3,
            singleRowWidgetOnTop,
            twoInARowDecorator,
            defaultSpacing,
          );
        } else {
          // Render three rows: one widget per row
          return _buildThreeRowLayout(
            widget1,
            widget2,
            widget3,
            defaultSpacing,
          );
        }
      },
    );
  }

  /// Determines if widgets should be rendered in a row based on condition type
  static bool _shouldRenderInRow(
    BoxConstraints constraints,
    Widget widget1,
    Widget widget2,
    TwoInARowDecorator decorator,
    TwoInARowConditionType conditionType,
    BuildContext context,
    TwoDimSpacing spacing,
  ) {
    return switch (conditionType) {
      _OverallWidthCondition(value: final threshold) =>
        constraints.maxWidth >= threshold,
      _Width1WidgetCondition(value: final threshold) =>
        _getWidgetWidth(widget1, constraints, context) >= threshold,
      _Width2WidgetCondition(value: final threshold) =>
        _getWidgetWidth(widget2, constraints, context) >= threshold,
      _AutoCondition() => _canFitInRow(
          widget1,
          widget2,
          decorator,
          constraints,
          context,
          spacing,
        ),
    };
  }

  /// Builds row layout for two widgets
  static Widget _buildRowLayout(
    Widget widget1,
    Widget widget2,
    TwoInARowDecorator decorator,
    TwoDimSpacing spacing,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final List<Widget> children = [];

        // Add first widget with appropriate sizing
        if (decorator.widthWidget1 != null) {
          final dimension1 = decorator.widthWidget1!;
          if (dimension1.type == DimensionType.fixed) {
            children.add(
              SizedBox(
                width: dimension1.value,
                child: widget1,
              ),
            );
          } else if (dimension1.type == DimensionType.expanded) {
            children.add(
              Expanded(
                child: widget1,
              ),
            );
          } else {
            // For percentage and flex, calculate actual width
            final calculatedWidth = dimension1
                .calculate(constraints.maxWidth - spacing.horizontalSpacing);
            children.add(
              SizedBox(
                width: calculatedWidth,
                child: widget1,
              ),
            );
          }
        } else {
          // If no dimension specified, use as-is
          children.add(widget1);
        }

        // Add spacing
        if (spacing.horizontalSpacing > 0) {
          children.add(SizedBox(width: spacing.horizontalSpacing));
        }

        // Add second widget with appropriate sizing
        if (decorator.widthWidget2 != null) {
          final dimension2 = decorator.widthWidget2!;
          if (dimension2.type == DimensionType.fixed) {
            children.add(
              SizedBox(
                width: dimension2.value,
                child: widget2,
              ),
            );
          } else if (dimension2.type == DimensionType.expanded) {
            children.add(
              Expanded(
                child: widget2,
              ),
            );
          } else {
            // For percentage and flex, calculate actual width
            final remainingWidth =
                constraints.maxWidth - spacing.horizontalSpacing;
            final calculatedWidth = dimension2.calculate(remainingWidth);
            children.add(
              SizedBox(
                width: calculatedWidth,
                child: widget2,
              ),
            );
          }
        } else {
          // If no dimension specified, use as-is
          children.add(widget2);
        }

        return Row(
          mainAxisAlignment: decorator.mainAxisAlignment,
          crossAxisAlignment: decorator.crossAxisAlignment,
          mainAxisSize: decorator.mainAxisSize,
          children: children,
        );
      },
    );
  }

  /// Builds column layout for two widgets
  static Widget _buildColumnLayout(
    Widget widget1,
    Widget widget2,
    TwoInARowDecorator decorator,
    TwoDimSpacing spacing,
  ) {
    return Column(
      mainAxisSize: decorator.mainAxisSize,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: decorator.mainAxisAlignment,
      children: [
        widget1,
        if (spacing.verticalSpacing > 0)
          SizedBox(height: spacing.verticalSpacing),
        widget2,
      ],
    );
  }

  /// Builds three widgets in a single row layout
  static Widget _buildThreeInRowLayout(
    Widget widget1,
    Widget widget2,
    Widget widget3,
    ThreeInARowDecorator decorator,
    TwoDimSpacing spacing,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final List<Widget> children = [];

        if (decorator.groupWidget == ThreeInARowGroupWidget.leftMiddle) {
          // Group first two widgets on the left, third widget on the right
          final leftGroup = _buildGroupedWidgets(
            widget1,
            widget2,
            decorator.widthWidget1,
            decorator.widthWidget2,
            spacing,
            constraints,
          );
          children.add(leftGroup);

          if (spacing.horizontalSpacing > 0) {
            children.add(SizedBox(width: spacing.horizontalSpacing));
          }

          children.add(
              _buildSizedWidget(widget3, decorator.widthWidget3, constraints));
        } else {
          // Group first widget on the left, last two widgets on the right
          children.add(
              _buildSizedWidget(widget1, decorator.widthWidget1, constraints));

          if (spacing.horizontalSpacing > 0) {
            children.add(SizedBox(width: spacing.horizontalSpacing));
          }

          final rightGroup = _buildGroupedWidgets(
            widget2,
            widget3,
            decorator.widthWidget2,
            decorator.widthWidget3,
            spacing,
            constraints,
          );
          children.add(rightGroup);
        }

        return Row(
          mainAxisAlignment: decorator.mainAxisAlignment,
          crossAxisAlignment: decorator.crossAxisAlignment,
          mainAxisSize: decorator.mainAxisSize,
          children: children,
        );
      },
    );
  }

  /// Builds two-row layout for three widgets
  static Widget _buildTwoRowLayout(
    Widget widget1,
    Widget widget2,
    Widget widget3,
    bool singleRowWidgetOnTop,
    TwoInARowDecorator twoInARowDecorator,
    TwoDimSpacing spacing,
  ) {
    if (singleRowWidgetOnTop) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget1,
          if (spacing.verticalSpacing > 0)
            SizedBox(height: spacing.verticalSpacing),
          _buildRowLayout(widget2, widget3, twoInARowDecorator, spacing),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRowLayout(widget1, widget2, twoInARowDecorator, spacing),
          if (spacing.verticalSpacing > 0)
            SizedBox(height: spacing.verticalSpacing),
          widget3,
        ],
      );
    }
  }

  /// Builds three-row layout for three widgets
  static Widget _buildThreeRowLayout(
    Widget widget1,
    Widget widget2,
    Widget widget3,
    TwoDimSpacing spacing,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget1,
        if (spacing.verticalSpacing > 0)
          SizedBox(height: spacing.verticalSpacing),
        widget2,
        if (spacing.verticalSpacing > 0)
          SizedBox(height: spacing.verticalSpacing),
        widget3,
      ],
    );
  }

  /// Helper method to build grouped widgets
  static Widget _buildGroupedWidgets(
    Widget widget1,
    Widget widget2,
    DynamicDimension? dimension1,
    DynamicDimension? dimension2,
    TwoDimSpacing spacing,
    BoxConstraints constraints,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSizedWidget(widget1, dimension1, constraints),
        if (spacing.horizontalSpacing > 0)
          SizedBox(width: spacing.horizontalSpacing),
        _buildSizedWidget(widget2, dimension2, constraints),
      ],
    );
  }

  /// Helper method to build a widget with specified dimensions
  static Widget _buildSizedWidget(
    Widget widget,
    DynamicDimension? dimension,
    BoxConstraints constraints,
  ) {
    if (dimension == null) {
      return widget;
    }

    switch (dimension.type) {
      case DimensionType.fixed:
        return SizedBox(
          width: dimension.value,
          child: widget,
        );
      case DimensionType.expanded:
        return Expanded(child: widget);
      case DimensionType.percentage:
      case DimensionType.flex:
        final calculatedWidth = dimension.calculate(constraints.maxWidth);
        return SizedBox(
          width: calculatedWidth,
          child: widget,
        );
    }
  }

  /// Gets the preferred width of a widget by measuring it
  static double _getWidgetWidth(
    Widget widget,
    BoxConstraints constraints,
    BuildContext context,
  ) {
    try {
      // Use a temporary render object to measure the widget
      final renderObject = _WidgetMeasurer(widget);
      return renderObject.getSize(constraints, context).width;
    } catch (e) {
      // If measurement fails, return a default value based on constraints
      return constraints.maxWidth *
          0.5; // Assume widget takes half the available width
    }
  }

  /// Checks if both widgets can fit in a row with the given decorator settings
  static bool _canFitInRow(
    Widget widget1,
    Widget widget2,
    TwoInARowDecorator decorator,
    BoxConstraints constraints,
    BuildContext context,
    TwoDimSpacing spacing,
  ) {
    // If using expanded or percentage/flex widths, they should fit
    if (decorator.widthWidget1?.type == DimensionType.expanded ||
        decorator.widthWidget2?.type == DimensionType.expanded ||
        decorator.widthWidget1?.type == DimensionType.percentage ||
        decorator.widthWidget2?.type == DimensionType.percentage ||
        decorator.widthWidget1?.type == DimensionType.flex ||
        decorator.widthWidget2?.type == DimensionType.flex) {
      return true;
    }

    // Calculate required width
    double requiredWidth = spacing.horizontalSpacing;

    if (decorator.widthWidget1?.type == DimensionType.fixed) {
      requiredWidth += decorator.widthWidget1!.value;
    } else if (decorator.widthWidget1 != null) {
      requiredWidth += decorator.widthWidget1!.calculate(constraints.maxWidth);
    } else {
      requiredWidth += _getWidgetWidth(widget1, constraints, context);
    }

    if (decorator.widthWidget2?.type == DimensionType.fixed) {
      requiredWidth += decorator.widthWidget2!.value;
    } else if (decorator.widthWidget2 != null) {
      requiredWidth += decorator.widthWidget2!.calculate(constraints.maxWidth);
    } else {
      requiredWidth += _getWidgetWidth(widget2, constraints, context);
    }

    return requiredWidth <= constraints.maxWidth;
  }

  /// Convenience method for common two-equal-width layout
  static Widget twoEqualWidthInRow(
    Widget widget1,
    Widget widget2, {
    double minWidth = 600,
    TwoDimSpacing? spacing,
  }) {
    return twoInARowThreshold(
      widget1,
      widget2,
      TwoInARowDecorator(
        widthWidget1: DynamicDimension.expanded(),
        widthWidget2: DynamicDimension.expanded(),
      ),
      TwoInARowConditionType.overallWidth(minWidth),
      spacing: spacing ?? TwoDimSpacing.both(16.0),
    );
  }

  /// Convenience method for fixed width + flexible width layout
  static Widget fixedAndFlexInRow(
    Widget fixedWidget,
    Widget flexWidget, {
    required double fixedWidth,
    TwoDimSpacing? spacing,
    double minOverallWidth = 400.0,
    bool fixedFirst = true,
  }) {
    final decorator = TwoInARowDecorator(
      widthWidget1: fixedFirst
          ? DynamicDimension.fix(fixedWidth)
          : DynamicDimension.expanded(),
      widthWidget2: fixedFirst
          ? DynamicDimension.expanded()
          : DynamicDimension.fix(fixedWidth),
    );

    return twoInARowThreshold(
      fixedFirst ? fixedWidget : flexWidget,
      fixedFirst ? flexWidget : fixedWidget,
      decorator,
      TwoInARowConditionType.overallWidth(minOverallWidth),
      spacing: spacing ?? TwoDimSpacing.both(8.0),
    );
  }

  /// Convenience method for auto-wrapping layout
  static Widget autoWrapTwoWidgets(
    Widget widget1,
    Widget widget2, {
    TwoDimSpacing? spacing,
  }) {
    return twoInARowThreshold(
      widget1,
      widget2,
      const TwoInARowDecorator(),
      const TwoInARowConditionType.auto(),
      spacing: spacing ?? TwoDimSpacing.both(8.0),
    );
  }

  /// Convenience method for one widget on left, two widgets on right layout
  static Widget oneLeftTwoRight(
    Widget widget1,
    Widget widget2,
    Widget widget3, {
    double threeInARowMinWidth = 800.0,
    double twoInARowMinWidth = 500.0,
    bool singleRowWidgetOnTop = true,
    TwoDimSpacing? spacing,
  }) {
    return threeInARowThreshold(
      widget1,
      widget2,
      widget3,
      threeInARowWidthThreshold: threeInARowMinWidth,
      threeInARowDecorator: const ThreeInARowDecorator(
        groupWidget: ThreeInARowGroupWidget.middleRight,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
      twoInARowWidthThreshold: twoInARowMinWidth,
      singleRowWidgetOnTop: singleRowWidgetOnTop,
      twoInARowDecorator: TwoInARowDecorator.flexEqual(),
      spacing: spacing ?? TwoDimSpacing.both(8.0),
    );
  }

  /// Convenience method for one widget on left, two widgets on right layout with flex sizing
  static Widget oneLeftTwoRightFlex({
    required Widget widget1,
    required Widget widget2,
    required Widget widget3,
    double threeInARowMinWidth = 800.0,
    double twoInARowMinWidth = 500.0,
    bool singleRowWidgetOnTop = true,
    TwoDimSpacing? spacing,
  }) {
    return threeInARowThreshold(
      widget1,
      widget2,
      widget3,
      threeInARowWidthThreshold: threeInARowMinWidth,
      threeInARowDecorator: ThreeInARowDecorator(
        widthWidget1: DynamicDimension.percentage(50), // 2/4 = 50%
        widthWidget2: DynamicDimension.percentage(25), // 1/4 = 25%
        widthWidget3: DynamicDimension.percentage(25), // 1/4 = 25%
        groupWidget: ThreeInARowGroupWidget.middleRight,
      ),
      twoInARowWidthThreshold: twoInARowMinWidth,
      singleRowWidgetOnTop: singleRowWidgetOnTop,
      twoInARowDecorator: TwoInARowDecorator.flexEqual(),
      spacing: spacing ?? TwoDimSpacing.both(8.0),
    );
  }

  /// Convenience method for two widgets on left, one widget on right layout
  static Widget twoLeftOneRight(
    Widget widget1,
    Widget widget2,
    Widget widget3, {
    double threeInARowMinWidth = 800.0,
    double twoInARowMinWidth = 500.0,
    bool singleRowWidgetOnTop = false,
    TwoDimSpacing? spacing,
  }) {
    return threeInARowThreshold(
      widget1,
      widget2,
      widget3,
      threeInARowWidthThreshold: threeInARowMinWidth,
      threeInARowDecorator: const ThreeInARowDecorator(
        groupWidget: ThreeInARowGroupWidget.leftMiddle,
      ),
      twoInARowWidthThreshold: twoInARowMinWidth,
      singleRowWidgetOnTop: singleRowWidgetOnTop,
      twoInARowDecorator: TwoInARowDecorator.flexEqual(),
      spacing: spacing ?? TwoDimSpacing.both(8.0),
    );
  }

  /// Convenience method for two widgets on left, one widget on right layout with flex sizing
  static Widget twoLeftOneRightFlex(
    Widget widget1,
    Widget widget2,
    Widget widget3, {
    double threeInARowMinWidth = 800.0,
    double twoInARowMinWidth = 500.0,
    bool singleRowWidgetOnTop = false,
    TwoDimSpacing? spacing,
  }) {
    return threeInARowThreshold(
      widget1,
      widget2,
      widget3,
      threeInARowWidthThreshold: threeInARowMinWidth,
      threeInARowDecorator: ThreeInARowDecorator(
        widthWidget1: DynamicDimension.percentage(25), // 1/4 = 25%
        widthWidget2: DynamicDimension.percentage(25), // 1/4 = 25%
        widthWidget3: DynamicDimension.percentage(50), // 2/4 = 50%
        groupWidget: ThreeInARowGroupWidget.leftMiddle,
      ),
      twoInARowWidthThreshold: twoInARowMinWidth,
      singleRowWidgetOnTop: singleRowWidgetOnTop,
      twoInARowDecorator: TwoInARowDecorator.flexEqual(),
      spacing: spacing ?? TwoDimSpacing.both(8.0),
    );
  }
}

/// Column profile for GridBuilderHelper auto-scaling
@immutable
class GridBuilderColumnProfile {
  final double widthThreshold;
  final int numberOfColumns;

  const GridBuilderColumnProfile({
    required this.widthThreshold,
    required this.numberOfColumns,
  });

  /// Factory method to create profiles based on minimum width per column
  ///
  /// [minWidthPerColumn] - minimum width each column should have
  /// [maxNumberOfColumns] - maximum number of columns to generate profiles for
  ///
  /// Example: minWidthPerColumn(400, 3) creates:
  /// - Profile(0, 1) - 1 column at 0 width (default)
  /// - Profile(800, 2) - 2 columns at 800 width (2 * 400)
  /// - Profile(1200, 3) - 3 columns at 1200 width (3 * 400)
  static List<GridBuilderColumnProfile> minWidthPerColumn(
    double minWidthPerColumn,
    int maxNumberOfColumns,
  ) {
    if (minWidthPerColumn <= 0) {
      throw ArgumentError.value(
        minWidthPerColumn,
        'minWidthPerColumn',
        'Must be greater than 0',
      );
    }
    if (maxNumberOfColumns <= 0) {
      throw ArgumentError.value(
        maxNumberOfColumns,
        'maxNumberOfColumns',
        'Must be greater than 0',
      );
    }

    final profiles = <GridBuilderColumnProfile>[];

    // Always start with 1 column at 0 width
    profiles.add(const GridBuilderColumnProfile(
      widthThreshold: 0,
      numberOfColumns: 1,
    ));

    // Generate profiles for each column count (starting from 2 columns)
    for (int columns = 2; columns <= maxNumberOfColumns; columns++) {
      final threshold = minWidthPerColumn * (columns - 1);
      profiles.add(GridBuilderColumnProfile(
        widthThreshold: threshold,
        numberOfColumns: columns,
      ));
    }

    return profiles;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridBuilderColumnProfile &&
        other.widthThreshold == widthThreshold &&
        other.numberOfColumns == numberOfColumns;
  }

  @override
  int get hashCode => widthThreshold.hashCode ^ numberOfColumns.hashCode;

  @override
  String toString() {
    return 'GridBuilderColumnProfile(widthThreshold: $widthThreshold, numberOfColumns: $numberOfColumns)';
  }
}

/// Decorator for customizing GridBuilderHelper appearance and behavior
@immutable
class GridBuilderDecorator {
  final EdgeInsetsGeometry? padding;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double? childAspectRatio;
  final Axis? scrollDirection;
  final bool? reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool? shrinkWrap;
  final EdgeInsetsGeometry? childPadding;
  final double? minChildHeight;
  final double? maxChildHeight;

  const GridBuilderDecorator({
    this.padding,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio,
    this.scrollDirection,
    this.reverse,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap,
    this.childPadding,
    this.minChildHeight,
    this.maxChildHeight,
  });

  GridBuilderDecorator copyWith({
    EdgeInsetsGeometry? padding,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    double? childAspectRatio,
    Axis? scrollDirection,
    bool? reverse,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool? shrinkWrap,
    EdgeInsetsGeometry? childPadding,
    double? minChildHeight,
    double? maxChildHeight,
  }) {
    return GridBuilderDecorator(
      padding: padding ?? this.padding,
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      reverse: reverse ?? this.reverse,
      controller: controller ?? this.controller,
      primary: primary ?? this.primary,
      physics: physics ?? this.physics,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      childPadding: childPadding ?? this.childPadding,
      minChildHeight: minChildHeight ?? this.minChildHeight,
      maxChildHeight: maxChildHeight ?? this.maxChildHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridBuilderDecorator &&
        other.padding == padding &&
        other.mainAxisSpacing == mainAxisSpacing &&
        other.crossAxisSpacing == crossAxisSpacing &&
        other.childAspectRatio == childAspectRatio &&
        other.scrollDirection == scrollDirection &&
        other.reverse == reverse &&
        other.controller == controller &&
        other.primary == primary &&
        other.physics == physics &&
        other.shrinkWrap == shrinkWrap &&
        other.childPadding == childPadding &&
        other.minChildHeight == minChildHeight &&
        other.maxChildHeight == maxChildHeight;
  }

  @override
  int get hashCode =>
      padding.hashCode ^
      mainAxisSpacing.hashCode ^
      crossAxisSpacing.hashCode ^
      childAspectRatio.hashCode ^
      scrollDirection.hashCode ^
      reverse.hashCode ^
      controller.hashCode ^
      primary.hashCode ^
      physics.hashCode ^
      shrinkWrap.hashCode ^
      childPadding.hashCode ^
      minChildHeight.hashCode ^
      maxChildHeight.hashCode;
}

/// Helper class for building responsive grids with auto-scaling columns
class GridBuilderHelper extends StatelessWidget {
  final List<GridBuilderColumnProfile> columnProfiles;
  final Widget Function(BuildContext context, int index) builder;
  final int itemCount;
  final GridBuilderDecorator? decorator;

  const GridBuilderHelper({
    super.key,
    required this.columnProfiles,
    required this.builder,
    required this.itemCount,
    this.decorator,
  });

  /// Validates column profiles to ensure they follow the rules:
  /// - Must have at least one profile
  /// - Must have a profile with widthThreshold 0 (default)
  /// - Profiles must be sorted by widthThreshold
  /// - Higher thresholds must have equal or more columns
  /// - No duplicate thresholds
  static void _validateProfiles(List<GridBuilderColumnProfile> profiles) {
    if (profiles.isEmpty) {
      throw ArgumentError('Column profiles cannot be empty');
    }

    // Sort profiles by width threshold
    final sortedProfiles = List<GridBuilderColumnProfile>.from(profiles)
      ..sort((a, b) => a.widthThreshold.compareTo(b.widthThreshold));

    // Check for default profile (threshold 0)
    if (sortedProfiles.first.widthThreshold != 0) {
      throw ArgumentError(
          'Must have a profile with widthThreshold 0 as default');
    }

    // Check for duplicates and validate column progression
    for (int i = 0; i < sortedProfiles.length - 1; i++) {
      final current = sortedProfiles[i];
      final next = sortedProfiles[i + 1];

      // Check for duplicate thresholds
      if (current.widthThreshold == next.widthThreshold) {
        throw ArgumentError(
          'Duplicate widthThreshold found: ${current.widthThreshold}',
        );
      }

      // Check that higher thresholds don't have fewer columns
      if (next.numberOfColumns < current.numberOfColumns) {
        throw ArgumentError(
          'Profile with higher threshold (${next.widthThreshold}) cannot have fewer columns (${next.numberOfColumns}) than lower threshold (${current.widthThreshold}) with ${current.numberOfColumns} columns',
        );
      }
    }
  }

  /// Determines the number of columns based on available width
  int _getColumnsForWidth(double width) {
    _validateProfiles(columnProfiles);

    final sortedProfiles = List<GridBuilderColumnProfile>.from(columnProfiles)
      ..sort((a, b) => a.widthThreshold.compareTo(b.widthThreshold));

    // Find the highest threshold that the width meets
    GridBuilderColumnProfile selectedProfile = sortedProfiles.first;
    for (final profile in sortedProfiles) {
      if (width >= profile.widthThreshold) {
        selectedProfile = profile;
      } else {
        break;
      }
    }

    return selectedProfile.numberOfColumns;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _getColumnsForWidth(constraints.maxWidth);

        // Calculate child aspect ratio if height constraints are specified
        double? aspectRatio = decorator?.childAspectRatio;
        if (aspectRatio == null &&
            (decorator?.minChildHeight != null ||
                decorator?.maxChildHeight != null)) {
          final itemWidth = (constraints.maxWidth -
                  (decorator?.padding?.horizontal ?? 0) -
                  ((columns - 1) * (decorator?.crossAxisSpacing ?? 4))) /
              columns;

          if (decorator?.minChildHeight != null) {
            aspectRatio = itemWidth / decorator!.minChildHeight!;
          } else if (decorator?.maxChildHeight != null) {
            aspectRatio = itemWidth / decorator!.maxChildHeight!;
          }
        }

        return GridView.builder(
          padding: decorator?.padding,
          scrollDirection: decorator?.scrollDirection ?? Axis.vertical,
          reverse: decorator?.reverse ?? false,
          controller: decorator?.controller,
          primary: decorator?.primary,
          physics: decorator?.physics,
          shrinkWrap: decorator?.shrinkWrap ?? false,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: decorator?.mainAxisSpacing ?? 4.0,
            crossAxisSpacing: decorator?.crossAxisSpacing ?? 4.0,
            childAspectRatio: aspectRatio ?? 1.0,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            Widget child = builder(context, index);

            // Apply child padding if specified
            if (decorator?.childPadding != null) {
              child = Padding(
                padding: decorator!.childPadding!,
                child: child,
              );
            }

            return child;
          },
        );
      },
    );
  }

  /// Convenience factory for common grid layouts
  static GridBuilderHelper responsive({
    required Widget Function(BuildContext context, int index) builder,
    required int itemCount,
    double minItemWidth = 200.0,
    int maxColumns = 4,
    GridBuilderDecorator? decorator,
  }) {
    return GridBuilderHelper(
      columnProfiles: GridBuilderColumnProfile.minWidthPerColumn(
        minItemWidth,
        maxColumns,
      ),
      builder: builder,
      itemCount: itemCount,
      decorator: decorator,
    );
  }

  /// Convenience factory for fixed column grid
  static GridBuilderHelper fixed({
    required Widget Function(BuildContext context, int index) builder,
    required int itemCount,
    required int columns,
    GridBuilderDecorator? decorator,
  }) {
    return GridBuilderHelper(
      columnProfiles: [
        GridBuilderColumnProfile(
          widthThreshold: 0,
          numberOfColumns: columns,
        ),
      ],
      builder: builder,
      itemCount: itemCount,
      decorator: decorator,
    );
  }
}
