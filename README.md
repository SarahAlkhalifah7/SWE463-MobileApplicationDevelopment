# SWE463 – Mobile Application Development

# Taskarro 🌟

Taskarro is a family task-management and reward application designed to help parents organize their children's daily responsibilities while motivating children through stars, rewards, progress tracking, streaks, challenges, and achievements.

The application is developed using **Flutter and Dart** as part of the SWE463 Mobile Application Development course.

## Project Overview

Taskarro provides two main experiences:

- **Parent Mode** – Parents can create accounts, manage children, assign tasks, create rewards, and monitor each child's progress.
- **Child Mode** – Children can access their profiles using a unique 4-digit code, view assigned missions, complete tasks, earn stars, and track their progress toward rewards and achievements.

## Features

### Parent Mode

- Parent account creation and login
- Form validation for account information
- Support for multiple parent accounts
- Duplicate email prevention
- Parent dashboard
- Add and edit child profiles
- Choose a child avatar or profile photo
- Automatically generate a unique 4-digit child access code
- Copy child access codes
- View and manage multiple children
- Create, edit, delete, and prioritize tasks
- Assign tasks to specific children
- Assign stars to tasks
- Schedule tasks with an optional due date and time
- Repeat tasks daily, weekly, or on custom weekdays
- Filter tasks by all, pending, and completed
- Track completed and pending tasks
- Create, edit, and delete rewards
- Set the number of stars required for each reward
- Give (redeem) a reward once the child has enough stars
- View available stars and reward progress
- View each child's task progress
- View earned stars and progress summaries
- Parent profile with account and child information
- Parent logout

### Child Mode

- Login using a unique 4-digit child access code
- Personalized child experience
- View today's missions (repeating tasks appear on their scheduled days)
- Complete assigned tasks
- Earn stars from completed tasks
- View available stars
- Track progress toward rewards
- View reward journey
- View streaks and weekly challenges
- View achievements and badges

## Main Screens

The application currently includes:

1. Welcome / Mode Selection
2. Parent Login
3. Parent Sign Up
4. Parent Dashboard
5. Add Child
6. Edit Child Profile
7. Parent Profile
8. Task Management
9. Add / Edit Task
10. Rewards Management
11. Parent Child Progress View
12. Child Code Login
13. Child Home / Daily Missions
14. Child Reward Progress
15. Child Challenges
16. Child Badges / Achievements

## User Flow

### Parent Flow

1. The user selects **Parent Mode**.
2. The parent creates an account or logs into an existing account.
3. The parent accesses the Parent Dashboard.
4. The parent adds one or more children.
5. Each child receives a unique 4-digit access code.
6. The parent creates and assigns tasks to a child.
7. The parent assigns stars to tasks.
8. The parent creates rewards and defines the required number of stars.
9. The child completes assigned tasks and earns stars.
10. The parent monitors task, star, and reward progress.
11. The parent can edit child information or copy the child's access code.
12. The parent can log out through the Profile screen.

### Child Flow

1. The user selects **Child Mode**.
2. The child enters their unique 4-digit access code.
3. Taskarro retrieves the child's profile.
4. The child views assigned tasks.
5. The child completes daily missions.
6. Completed tasks contribute stars to the child's account.
7. The child tracks progress toward available rewards.
8. The child can view challenges, streaks, badges, and achievements.

## Data and Persistence

Taskarro uses local persistence to store application data.

The application currently stores information including:

- Parent accounts
- Child profiles
- Child access codes
- Tasks
- Task completion status
- Rewards
- Reward redemption status

Stars are calculated from completed tasks and redeemed rewards rather than being stored separately, helping keep star totals consistent with task and reward data.

Each task keeps a completion history. Repeating tasks become pending again when their next scheduled day arrives, while the history keeps the stars already earned. Streaks, weekly challenges, and badges are calculated from this history.

## Technologies Used

- **Flutter**
- **Dart**
- **SharedPreferences**
- **Image Picker**
- **Material Design / Material 3**
- **Flutter Test**

## Project Structure



```text
taskarro/
├── lib/
│   ├── models/
│   │   ├── child.dart
│   │   ├── parent.dart
│   │   ├── reward.dart
│   │   └── task.dart
│   │
│   ├── screens/
│   │   ├── account_created.dart
│   │   ├── add_child.dart
│   │   ├── add_edit_task.dart
│   │   ├── child_badges.dart
│   │   ├── child_challenges.dart
│   │   ├── child_code_login.dart
│   │   ├── child_mode.dart
│   │   ├── child_progress.dart
│   │   ├── child_tasks.dart
│   │   ├── edit_child.dart
│   │   ├── parent_child_progress.dart
│   │   ├── parent_dashboard.dart
│   │   ├── parent_login.dart
│   │   ├── parent_mode.dart
│   │   ├── parent_profile.dart
│   │   ├── parent_signup.dart
│   │   ├── reward_form_dialog.dart
│   │   ├── rewards_management.dart
│   │   ├── task_management.dart
│   │   └── welcome_screen.dart
│   │
│   ├── services/
│   │   ├── account_storage.dart
│   │   ├── reward_storage.dart
│   │   ├── star_service.dart
│   │   ├── streak_service.dart
│   │   └── task_storage.dart
│   │
│   └── main.dart
│
├── test/
│   ├── storage_services_test.dart
│   ├── task_reward_models_test.dart
│   └── widget_test.dart
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── pubspec.yaml
└── README.md
```

### Architecture

Taskarro follows a simple separation of responsibilities:

- **Models** define the application's core data objects, including parents, children, tasks, and rewards.
- **Screens** contain the Parent and Child user interfaces and navigation flows.
- **Services** manage local persistence and shared application logic for accounts, tasks, rewards, and stars.
- **Tests** contain automated widget tests for important application flows and unit tests for the task and reward models, storage, and star calculations.

## Running the Application

Make sure Flutter is installed and configured.

Install the project dependencies:

```bash
flutter pub get
```

Check the available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

To run on a specific device:

```bash
flutter run -d <device-id>
```

## Testing

Run Flutter static analysis:

```bash
flutter analyze
```

Run the automated tests:

```bash
flutter test
```

The project should pass static analysis without errors before submission.

## Figma Prototype

The original Taskarro interface and user-flow prototype was designed in Figma:

https://www.figma.com/design/J7ngw6CZivyIVTvDuGVKDr/Taskaroo?node-id=0-1&t=qrQxCMDcT3PrRUI2-1

The Flutter implementation builds on the prototype while adding functional navigation, local persistence, account management, task management, rewards, and progress tracking.

## Team Contributions

### Batool Alawami (202160170) – Parent Accounts and Parent Experience

- Parent sign up and login
- Account validation and local persistence
- Parent Dashboard
- Add and edit child profiles
- Child access-code generation and copying
- Child avatar/photo selection
- Parent Profile and logout
- Parent child-progress view
- Integration of real task, star, and reward data into the parent experience

### Ola Alhodar (202283060) – Task and Reward Management

- Task and Reward data models with JSON support
- Task and reward local persistence (TaskStorage, RewardStorage)
- Star calculation service (StarService)
- Task Management screen with child selector, filters, and empty states
- Reusable Add / Edit Task form with validation
- Task priority, due date and time, and recurrence (daily, weekly, custom days)
- Edit, delete with confirmation, and quick priority change for tasks
- Rewards Management screen with star balance and reward progress
- Add, edit, delete, and give rewards
- Repeating-task completion history and daily reset
- Unit tests for models, storage, and star calculations

### Sarah Alkhalifa (202276880) – Child Experience and Progress

- Child access-code login
- Child task experience
- Task completion
- Child reward progress
- Streaks and weekly challenges
- Badges and achievements

## Current Development Status

The core Parent and Child flows are implemented and integrated with locally stored application data.

Task, star, and reward information is shared between the Parent and Child experiences so that progress can be reflected across the application.

Further development may include additional progress logic, expanded achievements, improved persistent profile-photo handling, and additional automated tests.

## AI Use Disclosure

The team designed Taskarro, created the Figma prototype, and planned the features, screens, and data model. The Flutter concepts covered in the course lectures (widgets and layouts, forms and validation, navigation, `setState`, and local storage with SharedPreferences) were applied by the team throughout the project.

Generative AI (Claude) was used as a coding assistant to:

- help write and connect code across the parent and child screens, models, and services
- implement more complex logic, such as recurring task scheduling and reset, completion history, and star, streak, and reward calculations
- debug errors, write unit tests, and explain code and Flutter concepts

All AI-assisted code was reviewed, run, and tested by the team on the Android emulator, and the team can explain how every part of the application works.