# Portfolio App - Screen Routes & URLs

## Base URLs
Your portfolio app is deployed on Firebase Hosting with the following base URLs:

- **Primary URL**: `https://portfolio-7474e.web.app`
- **Alternative URL**: `https://portfolio-7474e.firebaseapp.com`

---

## Available Screens & Routes

### 1. Home Screen
- **Route**: `/` or `/home`
- **Full URL**: `https://portfolio-7474e.web.app/`
- **Full URL (alt)**: `https://portfolio-7474e.firebaseapp.com/`
- **Description**: Main landing page with navigation

### 2. Projects Screen
- **Route**: `/projects`
- **Full URL**: `https://portfolio-7474e.web.app/projects`
- **Full URL (alt)**: `https://portfolio-7474e.firebaseapp.com/projects`
- **Description**: Portfolio projects showcase

### 3. Skills Screen
- **Route**: `/skills`
- **Full URL**: `https://portfolio-7474e.web.app/skills`
- **Full URL (alt)**: `https://portfolio-7474e.firebaseapp.com/skills`
- **Description**: Technical skills and competencies

### 4. Experience Screen
- **Route**: `/experience`
- **Full URL**: `https://portfolio-7474e.web.app/experience`
- **Full URL (alt)**: `https://portfolio-7474e.firebaseapp.com/experience`
- **Description**: Work experience and learning journey

### 5. GitHub Screen
- **Route**: `/github`
- **Full URL**: `https://portfolio-7474e.web.app/github`
- **Full URL (alt)**: `https://portfolio-7474e.firebaseapp.com/github`
- **Description**: GitHub contributions and activity

### 6. LeetCode Screen
- **Route**: `/leetcode`
- **Full URL**: `https://portfolio-7474e.web.app/leetcode`
- **Full URL (alt)**: `https://portfolio-7474e.firebaseapp.com/leetcode`
- **Description**: LeetCode problem-solving statistics

### 7. About/Connect Screen
- **Route**: `/about` or `/connect`
- **Full URL**: `https://portfolio-7474e.web.app/about`
- **Full URL (alt)**: `https://portfolio-7474e.firebaseapp.com/about`
- **Description**: About me and social media connections

### 8. Blog Screen
- **Route**: `/blog`
- **Full URL**: `https://portfolio-7474e.web.app/blog`
- **Full URL (alt)**: `https://portfolio-7474e.firebaseapp.com/blog`
- **Description**: Blog posts and articles

---

## Quick Copy URLs

### Home
```
https://portfolio-7474e.web.app/
```

### Projects
```
https://portfolio-7474e.web.app/projects
```

### Skills
```
https://portfolio-7474e.web.app/skills
```

### Experience
```
https://portfolio-7474e.web.app/experience
```

### GitHub
```
https://portfolio-7474e.web.app/github
```

### LeetCode
```
https://portfolio-7474e.web.app/leetcode
```

### About/Connect
```
https://portfolio-7474e.web.app/about
```

### Blog
```
https://portfolio-7474e.web.app/blog
```

---

## Important Notes

⚠️ **URL Routing Setup Required**: 
Currently, your Flutter app uses a `PageController` for navigation, which doesn't support URL routing. For these URLs to work properly in browsers, you'll need to implement URL routing using one of these approaches:

1. **go_router** (Recommended): Add `go_router` package and set up named routes
2. **Flutter Web Router**: Use Flutter's built-in routing with `MaterialApp.router`
3. **auto_route**: Another popular routing solution

Once URL routing is implemented, users will be able to:
- Share direct links to specific screens
- Use browser back/forward buttons
- Bookmark specific pages
- Open pages directly via URL

---

## Custom Domain (Optional)

If you have configured a custom domain for your Firebase Hosting, replace `portfolio-7474e.web.app` with your custom domain in all URLs above.

Example: If your custom domain is `pratik.dev`, the home URL would be:
```
https://pratik.dev/
```

---

## Last Updated
Generated on: $(date)
