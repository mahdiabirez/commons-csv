# Phase 6: Security Analysis - Setup Guide

This document provides step-by-step instructions to configure GitGuardian, Snyk, and SonarCloud for the Apache Commons CSV project.

## Overview

Three security tools have been integrated:
1. **GitGuardian** - Secrets detection (API keys, tokens, passwords)
2. **Snyk** - Dependency vulnerability scanning (CVEs in Maven dependencies)
3. **SonarCloud** - Code quality and security analysis (vulnerabilities, code smells, security hotspots)

---

## 1. GitGuardian Setup

### What it does:
- Scans commits for exposed secrets (API keys, tokens, credentials)
- Prevents accidental secret leaks
- Free for public repositories

### Setup Steps:

#### Option A: GitHub App (Recommended - Easier)
1. Go to https://www.gitguardian.com/
2. Click "Sign up" and select "Continue with GitHub"
3. Install the GitGuardian GitHub App on your repository
4. Grant permissions to `mahdiabirez/commons-csv`
5. Done! GitGuardian will automatically scan new commits

#### Option B: API Key (Manual Setup)
1. Go to https://dashboard.gitguardian.com/
2. Sign up or log in
3. Navigate to: Settings → API → Personal Access Token
4. Click "Create Token" with "Scan" permission
5. Copy the token
6. Go to your GitHub repo: https://github.com/mahdiabirez/commons-csv/settings/secrets/actions
7. Click "New repository secret"
8. Name: `GITGUARDIAN_API_KEY`
9. Value: Paste your token
10. Click "Add secret"

### Verify:
- Push a commit and check: https://github.com/mahdiabirez/commons-csv/actions
- Look for "GitGuardian Secrets Scan" workflow

---

## 2. Snyk Setup

### What it does:
- Scans Maven dependencies for known vulnerabilities (CVEs)
- Provides upgrade recommendations
- Free for open source projects

### Setup Steps:

1. **Get your Snyk token:**
   - Go to https://app.snyk.io/
   - Log in to your Snyk account
   - Navigate to: Account Settings (click your name → Account settings)
   - Scroll to "API Token" section
   - Click "Show" and copy your token (starts with "snyk-...")

2. **Add token to GitHub:**
   - Go to: https://github.com/mahdiabirez/commons-csv/settings/secrets/actions
   - Click "New repository secret"
   - Name: `SNYK_TOKEN`
   - Value: Paste your Snyk token
   - Click "Add secret"

3. **Connect Snyk to GitHub (Optional - for dashboard):**
   - In Snyk dashboard: https://app.snyk.io/
   - Click "Add project"
   - Select "GitHub"
   - Find and import `mahdiabirez/commons-csv`
   - This enables the Snyk web dashboard

### Verify:
- Push a commit and check: https://github.com/mahdiabirez/commons-csv/actions
- Look for "Snyk Security Scan" workflow
- Check results in: https://github.com/mahdiabirez/commons-csv/security/code-scanning

---

## 3. SonarCloud Setup

### What it does:
- Analyzes code quality and security
- Detects bugs, vulnerabilities, code smells
- Tracks technical debt
- Free for public repositories

### Setup Steps:

1. **Import project to SonarCloud:**
   - Go to https://sonarcloud.io/
   - Log in with GitHub
   - Click "+" (top right) → "Analyze new project"
   - Select `mahdiabirez/commons-csv`
   - Click "Set Up"
   - Choose "With GitHub Actions"

2. **Get SonarCloud token:**
   - In SonarCloud setup wizard, copy the token provided
   - OR go to: Account → Security → Generate Tokens
   - Generate a token with name "GitHub Actions"

3. **Add token to GitHub:**
   - Go to: https://github.com/mahdiabirez/commons-csv/settings/secrets/actions
   - Click "New repository secret"
   - Name: `SONAR_TOKEN`
   - Value: Paste your SonarCloud token
   - Click "Add secret"

4. **Verify Organization and Project Key:**
   - In `pom.xml`, these properties are configured:
     ```xml
     <sonar.organization>mahdiabirez</sonar.organization>
     <sonar.projectKey>mahdiabirez_commons-csv</sonar.projectKey>
     ```
   - If your SonarCloud organization is different, update these values
   - To check: Look at the URL in SonarCloud (e.g., sonarcloud.io/organizations/YOUR-ORG)

### Verify:
- Push a commit and check: https://github.com/mahdiabirez/commons-csv/actions
- Look for "SonarCloud Analysis" workflow
- View results at: https://sonarcloud.io/project/overview?id=mahdiabirez_commons-csv

---

## Quick Setup Summary

### GitHub Secrets to Add:
| Secret Name | Source | Required For |
|------------|--------|-------------|
| `GITGUARDIAN_API_KEY` | https://dashboard.gitguardian.com/api | GitGuardian workflow |
| `SNYK_TOKEN` | https://app.snyk.io/account | Snyk workflow |
| `SONAR_TOKEN` | https://sonarcloud.io/account/security | SonarCloud workflow |

### Files Created:
- `.github/workflows/gitguardian.yml` - GitGuardian secrets scanning
- `.github/workflows/snyk.yml` - Snyk dependency scanning
- `.github/workflows/sonarcloud.yml` - SonarCloud code analysis
- `pom.xml` - Updated with SonarCloud properties

---

## Running Scans Locally (Optional)

### Snyk Local Scan:
```bash
# Install Snyk CLI
npm install -g snyk

# Authenticate
snyk auth

# Scan dependencies
snyk test

# Scan and fix vulnerabilities
snyk test --all-projects
```

### SonarCloud Local Scan:
```bash
# Run analysis locally (requires SONAR_TOKEN environment variable)
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=mahdiabirez_commons-csv \
  -Dsonar.organization=mahdiabirez \
  -Dsonar.host.url=https://sonarcloud.io \
  -Dsonar.login=$SONAR_TOKEN
```

---

## Viewing Results

### GitGuardian:
- **GitHub Actions:** https://github.com/mahdiabirez/commons-csv/actions
- **GitGuardian Dashboard:** https://dashboard.gitguardian.com/

### Snyk:
- **GitHub Security Tab:** https://github.com/mahdiabirez/commons-csv/security/code-scanning
- **Snyk Dashboard:** https://app.snyk.io/
- Results show CVE IDs, severity, and fix recommendations

### SonarCloud:
- **SonarCloud Dashboard:** https://sonarcloud.io/project/overview?id=mahdiabirez_commons-csv
- Shows:
  - Bugs
  - Vulnerabilities
  - Security Hotspots
  - Code Smells
  - Code Coverage
  - Duplication

---

## Troubleshooting

### "SonarCloud organization not found"
- Update `<sonar.organization>` in `pom.xml` with your actual SonarCloud organization name
- Check: https://sonarcloud.io/account/organizations

### "Snyk authentication failed"
- Verify `SNYK_TOKEN` secret is correctly set
- Token must start with `snyk-`
- Generate a new token if needed: https://app.snyk.io/account

### "GitGuardian workflow not running"
- If using GitHub App method, no secret is needed
- If using API key method, verify `GITGUARDIAN_API_KEY` secret is set
- Check workflow permissions in: https://github.com/mahdiabirez/commons-csv/settings/actions

### Workflow fails with "Maven build failed"
- Ensure Java 21 is being used (configured in workflows)
- Check if dependencies resolve correctly
- Run `mvn clean install` locally to verify

---

## Next Steps After Setup

1. **Push this commit** to trigger all workflows
2. **Wait for workflows to complete** (5-10 minutes)
3. **Review security findings:**
   - GitGuardian: Check for any exposed secrets
   - Snyk: Review CVEs in dependencies
   - SonarCloud: Analyze security hotspots and vulnerabilities
4. **Document findings** in PROJECT_PROGRESS.md
5. **Create remediation plan** for high-severity issues

---

## Academic Project Notes

For your dependability analysis report, include:
- **Number of vulnerabilities** found by each tool
- **Severity breakdown** (Critical/High/Medium/Low)
- **Top 5 security issues** and remediation strategies
- **Code quality metrics** from SonarCloud
- **Screenshots** of dashboard results
- **Comparison** with industry standards

All three tools provide comprehensive reports suitable for academic documentation.
