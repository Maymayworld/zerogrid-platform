// lib/features/organizer/campaign/presentation/pages/create/loading_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:zero_grid/l10n/app_localizations.dart';
import 'package:zero_grid/shared/theme/app_theme.dart';

class LoadingPage extends HookWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
        onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: ColorPalette.smashedPumpkin600,
                ),
              ),
              SizedBox(height: SpacePalette.base),
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context)!.projectComingToLife,
                  style: TextStylePalette.smallHeader,
                ),
              ),
              SizedBox(height: SpacePalette.sm),
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context)!.projectReadyMessage,
                  style: TextStylePalette.subText,
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}