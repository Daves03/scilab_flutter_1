import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/user_model.dart';
import '../models/course_model.dart';
import '../services/auth_service.dart';
import '../presentation/teacher_ar_and_video_lesson_screen/teacher_ar_and_video_lesson_screen.dart';
import '../presentation/student_ar_and_video_lesson_screen/student_ar_and_video_lesson_screen.dart';
import '../presentation/student_home_screen/student_home_screen.dart';
import '../presentation/teacher_home_screen/teacher_home_screen.dart';
import '../presentation/overview_screen/overview_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';
import '../presentation/sign_up_login_screen/google_complete_profile_screen.dart';
import '../presentation/pending_approval_screen/pending_approval_screen.dart';
import '../presentation/student_courses_screen/student_courses_screen.dart';
import '../presentation/teacher_courses_screen/teacher_courses_screen.dart';
import '../presentation/teacher_progress_screen/teacher_progress_screen.dart';
import '../presentation/student_progress_screen/student_progress_screen.dart';
import '../presentation/teacher_profile_screen/teacher_profile_screen.dart';
import '../presentation/student_profile_screen/student_profile_screen.dart';
import '../presentation/unity_ar_screen/unity_ar_screen.dart';
import '../widgets/app_scaffold.dart';

class AppRoutes {
  static const String initial = '/';
  static const String overviewScreen = '/overview';
  static const String signUpLoginScreen = '/auth';
  static const String googleCompleteProfileScreen = '/google-complete-profile';
  static const String pendingApprovalScreen = '/pending-approval';
  static const String studentHomeScreen = '/student-home-screen';
  static const String teacherHomeScreen = '/teacher-home-screen';
  static const String teacherArAndVideoLessonScreen =
      '/teacher-ar-and-video-lesson-screen';
  static const String studentArAndVideoLessonScreen =
      '/student-ar-and-video-lesson-screen';
  static const String studentCoursesScreen = '/student-courses-screen';
  static const String teacherCoursesScreen = '/teacher-courses-screen';
  static const String teacherProfileScreen = '/teacher-profile-screen';
  static const String studentProfileScreen = '/student-profile-screen';
  static const String teacherProgressScreen = '/teacher-progress-screen';
  static const String studentProgressScreen = '/student-progress-screen';
  static const String unityArScreen = '/unity-ar';

  static GoRouter get router => appRouter;
}

const _publicRoutes = {
  AppRoutes.initial,
  AppRoutes.overviewScreen,
  AppRoutes.signUpLoginScreen,
  AppRoutes.googleCompleteProfileScreen,
  AppRoutes.pendingApprovalScreen,
};

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  refreshListenable: AuthService.instance,
  redirect: (context, state) {
    final auth = AuthService.instance;
    final path = state.matchedLocation;

    if (!auth.isLoggedIn) {
      return _publicRoutes.contains(path) ? null : AppRoutes.overviewScreen;
    }

    if (!auth.isApproved) {
      if (auth.currentUser?.role == null) {
        return path == AppRoutes.googleCompleteProfileScreen ? null : AppRoutes.googleCompleteProfileScreen;
      }
      return path == AppRoutes.pendingApprovalScreen ? null : AppRoutes.pendingApprovalScreen;
    }

    final isTeacher = auth.currentUser?.role == UserRole.teacher;

    // Fully approved: bounce away from the pre-auth screens into the
    // right role's home.
    if (_publicRoutes.contains(path)) {
      return isTeacher ? AppRoutes.teacherHomeScreen : AppRoutes.studentHomeScreen;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.initial,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OverviewScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.overviewScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OverviewScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.signUpLoginScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignUpLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.pendingApprovalScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PendingApprovalScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.googleCompleteProfileScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const GoogleCompleteProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: AppRoutes.unityArScreen,
      builder: (context, state) => 
        UnityArScreen(experimentId: state.uri.queryParameters['experimentId']),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.studentHomeScreen,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const StudentHomeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
            GoRoute(
              path: AppRoutes.teacherHomeScreen,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const TeacherHomeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.studentCoursesScreen,
              pageBuilder: (context, state) {
                final course = state.extra as Course?;
                return CustomTransitionPage(
                key: state.pageKey,
                child: StudentCoursesScreen(initialCourse: course),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 280),
              );
              },
            ),
            GoRoute(
              path: AppRoutes.teacherCoursesScreen,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const TeacherCoursesScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.teacherArAndVideoLessonScreen,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const TeacherArAndVideoLessonScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
            GoRoute(
              path: AppRoutes.studentArAndVideoLessonScreen,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const StudentArAndVideoLessonScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.teacherProgressScreen,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const TeacherProgressScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
            GoRoute(
              path: AppRoutes.studentProgressScreen,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const StudentProgressScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.teacherProfileScreen,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const TeacherProfileScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
            GoRoute(
              path: AppRoutes.studentProfileScreen,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const StudentProfileScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

// Alias for backward compatibility
final GoRouter router = appRouter;
