# 🛠️ Ostrum App DevOps Policy

## 📦 Development Environment Setup

To configure the development environment on your system, please follow the steps outlined below:

- ✅ Request the following files from the source code administrator:
    
    * amplify_config.base64
    * ssl_pinning_key.base64
    * ssl_pinning_key_beta.base64

- ✅ Place all three files in the following directory within your project: `assets/raw/dev/`
- ✅ Navigate to the file `lib/app/app_mode.dart`
- ✅ Locate the variable `oaMode` and set its value to `developer`
- ✅ <ins>These steps are intended for development purposes only. Ensure that any changes made for development are reverted before deploying to production!</ins>

________________________________________________________________________________________________________________________________________________________________

## Build 📦 & Release 🚀 Process

### Automate multiple build and release types using the workflow specified in .github/workflows/release.yml.

### ✅ Different Types of Builds:

| Sl. No. | Description | Commit Tag |
| ---------- | ---------- | ---------- |
| 1 | Only APK | B*/V*/APK |
| 2 | Only AAB  | B*/V*/AAB  |

### ✅ Different Types of Releases:

| Column 1   | Column 2   | Column 3   |
| ---------- | ---------- | ---------- |
| Row1Cell1  | Row1Cell2  | Row1Cell3  |
| Row2Cell1  | Row2Cell2  | Row2Cell3  |


________________________________________________________________________________________________________________________________________________________________

## 🔄 Pull Request Creation Process

### To maintain code quality and ensure proper review workflows, developers are not permitted to push code directly to the `PRE-DEV` branch. Instead, all changes must be integrated via a Pull Request (PR) using the Integrated DevOps Flow as defined in .github/workflows/devops_flow.yml.

### ✅ Steps to Create a Pull Request

  1. Run the following commands in the root directory of the repository to validate your changes:
  
    * flutter clean
    * flutter pub get
    * flutter analyze
    * trivy fs --exit-code 1 --severity HIGH,CRITICAL,LOW,MEDIUM,UNKNOWN `/PROJECT_PATH`
    * flutter test --coverage (ignore if Unit Test is not up-to date)

  2. Note: Replace `/PROJECT_PATH` with the actual path to your project directory. 
  3. Navigate to `workflow.json`.
  4. Enter all required information for each value in the JSON object, ensuring accuracy and completeness.
  5. After updating the JSON file and committing all changes, increment the Pull Request tag.
  6. The PR tag should follow the format PR-`number`. For example, if the previous PR was tagged as PR-167, the next should be PR-168.
  7. Commit and push your changes to your respective feature or development branch, ensuring the PR tag is updated as described above.
  8. Follow your repository’s standard process to open a new Pull Request from your `feature/development` branch into the `PRE-DEV` branch.
  9. Ensure all required details and reviewers are specified as per project guidelines.

________________________________________________________________________________________________________________________________________________________________

## 🔍 Pull Request Review Process

 * PR reviewers are configured using GitHub variables at the time of PR creation.
 * While any developer may review the PR and provide feedback or raise concerns, *only the designated PR reviewers are authorized to approve the Pull Request.*
 * Once one of the assigned PR reviewers have approved the Pull Request, an automated process will be triggered to merge the PR into the PRE-DEV branch.
 * No manual merging is required; the auto-merge process ensures consistency and compliance with the workflow.

________________________________________________________________________________________________________________________________________________________________
