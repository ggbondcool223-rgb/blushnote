import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blush_note/utils/colors.dart';
import 'package:blush_note/pages/blush_note_tab/blush_note_tab_view.dart';
import 'package:blush_note/pages/blush_note_tab/blush_note_tab_binding.dart';
import 'package:blush_note/pages/blush_note_home/blush_note_home_view.dart';
import 'package:blush_note/pages/blush_note_home/blush_note_home_binding.dart';
import 'package:blush_note/pages/blush_note_handbook_list/blush_note_handbook_list_view.dart';
import 'package:blush_note/pages/blush_note_handbook_list/blush_note_handbook_list_binding.dart';
import 'package:blush_note/pages/blush_note_handbook_edit/blush_note_handbook_edit_view.dart';
import 'package:blush_note/pages/blush_note_handbook_edit/blush_note_handbook_edit_binding.dart';
import 'package:blush_note/pages/blush_note_diary_list/blush_note_diary_list_view.dart';
import 'package:blush_note/pages/blush_note_diary_list/blush_note_diary_list_binding.dart';
import 'package:blush_note/pages/blush_note_diary_edit/blush_note_diary_edit_view.dart';
import 'package:blush_note/pages/blush_note_diary_edit/blush_note_diary_edit_binding.dart';
import 'package:blush_note/pages/blush_note_diary_notebook_add/blush_note_diary_notebook_add_view.dart';
import 'package:blush_note/pages/blush_note_diary_notebook_add/blush_note_diary_notebook_add_binding.dart';
import 'package:blush_note/pages/blush_note_accounting/blush_note_accounting_view.dart';
import 'package:blush_note/pages/blush_note_accounting/blush_note_accounting_binding.dart';
import 'package:blush_note/pages/blush_note_accounting_add/blush_note_accounting_add_view.dart';
import 'package:blush_note/pages/blush_note_accounting_add/blush_note_accounting_add_binding.dart';
import 'package:blush_note/pages/blush_note_schedule/blush_note_schedule_view.dart';
import 'package:blush_note/pages/blush_note_schedule/blush_note_schedule_binding.dart';
import 'package:blush_note/pages/blush_note_schedule_add/blush_note_schedule_add_view.dart';
import 'package:blush_note/pages/blush_note_schedule_add/blush_note_schedule_add_binding.dart';
import 'package:blush_note/pages/blush_note_settings/blush_note_settings_view.dart';
import 'package:blush_note/pages/blush_note_settings/blush_note_settings_binding.dart';
import 'package:blush_note/pages/blush_note_statistics/blush_note_statistics_view.dart';
import 'package:blush_note/pages/blush_note_statistics/blush_note_statistics_binding.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initDatabase();
  
  await Get.putAsync(() async {
    final service = NotificationService();
    await service.init();
    return service;
  });
  
  await notificationService.checkDueSchedules();

  runApp(const BlushNoteApp());
}

class BlushNoteApp extends StatelessWidget {
  const BlushNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'BlushNote',
          debugShowCheckedModeBanner: false,
          getPages: Blush,
          initialRoute: '/blush_tab',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: BlushNoteColors.primary,
            scaffoldBackgroundColor: BlushNoteColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: BlushNoteColors.primary,
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF333333),
              ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(size: 22, color: Color(0xFF333333)),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            dividerTheme: DividerThemeData(
              thickness: 1,
              color: Colors.grey[200],
            ),
          ),
          builder: (context, child) {
            return GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: child,
            );
          },
        );
      },
    );
  }
}
List<GetPage<dynamic>> Blush = [
  GetPage(
    name: '/blush_tab',
    page: () => const BlushNoteTabView(),
    binding: BlushNoteTabBinding(),
  ),
  GetPage(
    name: '/blush_home',
    page: () => const BlushNoteHomeView(),
    binding: BlushNoteHomeBinding(),
  ),
  GetPage(
    name: '/handbook',
    page: () => const BlushNoteHandbookListView(),
    binding: BlushNoteHandbookListBinding(),
  ),
  GetPage(
    name: '/handbook/edit',
    page: () => const BlushNoteHandbookEditView(),
    binding: BlushNoteHandbookEditBinding(),
  ),
  GetPage(
    name: '/diary',
    page: () => const BlushNoteDiaryListView(),
    binding: BlushNoteDiaryListBinding(),
  ),
  GetPage(
    name: '/diary/edit',
    page: () => const BlushNoteDiaryEditView(),
    binding: BlushNoteDiaryEditBinding(),
  ),
  GetPage(
    name: '/diary/notebook/add',
    page: () => const BlushNoteDiaryNotebookAddView(),
    binding: BlushNoteDiaryNotebookAddBinding(),
  ),
  GetPage(
    name: '/accounting',
    page: () => const BlushNoteAccountingView(),
    binding: BlushNoteAccountingBinding(),
  ),
  GetPage(
    name: '/accounting/add/income',
    page: () => const BlushNoteAccountingAddView(isIncome: true),
    binding: BlushNoteAccountingAddBinding(),
  ),
  GetPage(
    name: '/accounting/add/expense',
    page: () => const BlushNoteAccountingAddView(isIncome: false),
    binding: BlushNoteAccountingAddBinding(),
  ),
  GetPage(
    name: '/schedule',
    page: () => const BlushNoteScheduleView(),
    binding: BlushNoteScheduleBinding(),
  ),
  GetPage(
    name: '/schedule/add',
    page: () => const BlushNoteScheduleAddView(),
    binding: BlushNoteScheduleAddBinding(),
  ),
  GetPage(
    name: '/blush_settings',
    page: () => const BlushNoteSettingsView(),
    binding: BlushNoteSettingsBinding(),
  ),
  GetPage(
    name: '/blush_statistics',
    page: () => const BlushNoteStatisticsView(),
    binding: BlushNoteStatisticsBinding(),
  ),
];