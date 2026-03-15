<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — EduQR</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --ink: #0d1117; --paper: #f5f0e8; --accent: #e8490f;
            --accent2: #1a56e8; --muted: #6b7280; --border: #e2d9cc;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--ink);
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            position: relative; overflow: hidden;
        }

        /* Decorative background grid */
        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image:
                linear-gradient(rgba(232,73,15,.08) 1px, transparent 1px),
                linear-gradient(90deg, rgba(232,73,15,.08) 1px, transparent 1px);
            background-size: 48px 48px;
        }

        /* Large decorative text */
        body::after {
            content: 'EduQR';
            position: fixed; bottom: -40px; right: -20px;
            font-family: 'Syne', sans-serif;
            font-size: 18vw; font-weight: 800;
            color: rgba(255,255,255,.02);
            pointer-events: none; user-select: none;
            white-space: nowrap;
        }

        .login-wrap {
            position: relative; z-index: 1;
            width: 100%; max-width: 440px;
            padding: 20px;
        }

        /* Top brand bar */
        .brand {
            text-align: center; margin-bottom: 32px;
        }
        .brand-logo {
            display: inline-block;
            font-family: 'Syne', sans-serif;
            font-size: 1.5rem; font-weight: 800;
            color: #fff; letter-spacing: -1px;
        }
        .brand-logo span { color: var(--accent); }
        .brand-subtitle {
            display: block; font-size: 0.8rem;
            color: rgba(255,255,255,0.4);
            margin-top: 4px;
        }

        .card {
            background: var(--paper);
            border-radius: 16px;
            overflow: hidden;
        }

        .card-header {
            background: var(--accent);
            padding: 28px 36px 24px;
        }
        .card-header h1 {
            font-family: 'Syne', sans-serif;
            font-size: 1.6rem; font-weight: 800;
            color: #fff; letter-spacing: -0.5px;
            margin-bottom: 4px;
        }
        .card-header p { font-size: 0.85rem; color: rgba(255,255,255,0.75); }

        .card-body { padding: 32px 36px; }

        .form-group { margin-bottom: 20px; }
        .form-label {
            display: block;
            font-size: 0.8rem; font-weight: 500;
            letter-spacing: 0.5px; text-transform: uppercase;
            color: var(--muted); margin-bottom: 8px;
        }
        .form-control {
            width: 100%; padding: 13px 16px;
            background: #fff;
            border: 1.5px solid var(--border);
            border-radius: 8px;
            font-family: 'DM Sans', sans-serif;
            font-size: 0.95rem; color: var(--ink);
            transition: border-color .2s, box-shadow .2s;
            outline: none;
        }
        .form-control:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(232,73,15,.12);
        }

        .btn-login {
            width: 100%; padding: 14px;
            background: var(--ink); color: #fff;
            border: none; border-radius: 8px;
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 700;
            cursor: pointer; letter-spacing: 0.5px;
            transition: background .2s, transform .15s;
            margin-top: 8px;
        }
        .btn-login:hover { background: #1c2733; transform: translateY(-1px); }
        .btn-login:active { transform: translateY(0); }

        .divider {
            display: flex; align-items: center; gap: 12px;
            margin: 24px 0;
        }
        .divider::before, .divider::after {
            content: ''; flex: 1; height: 1px; background: var(--border);
        }
        .divider span { font-size: 0.75rem; color: var(--muted); white-space: nowrap; }

        .register-link {
            display: block; width: 100%; padding: 13px;
            background: transparent;
            border: 1.5px solid var(--border); border-radius: 8px;
            font-family: 'DM Sans', sans-serif;
            font-size: 0.9rem; font-weight: 500;
            color: var(--ink); text-align: center;
            text-decoration: none;
            transition: border-color .2s, background .2s;
        }
        .register-link:hover { border-color: var(--ink); background: rgba(13,17,23,.05); }

        .back-btn {
            display: flex; align-items: center; justify-content: center;
            gap: 6px; margin-bottom: 20px;
            color: rgba(255,255,255,.5); text-decoration: none;
            font-size: 0.85rem; transition: color .2s;
        }
        .back-btn:hover { color: #fff; }

        .error-msg {
            background: #fef2f2; border: 1px solid #fecaca;
            color: #b91c1c; border-radius: 8px;
            padding: 12px 16px; font-size: 0.875rem;
            margin-bottom: 20px; display: flex; gap: 8px; align-items: center;
        }

        /* Fade-in animation */
        @keyframes fadeUp {
            from { opacity:0; transform: translateY(20px); }
            to   { opacity:1; transform: translateY(0); }
        }
        .login-wrap { animation: fadeUp .5s ease both; }
    </style>
</head>
<body>
    <div class="login-wrap">
        <a href="index.jsp" class="back-btn">← Back to Home</a>

        <div class="brand">
            <div class="brand-logo">Edu<span>QR</span></div>
            <span class="brand-subtitle">Student Data & QR Management System</span>
        </div>

        <div class="card">
            <div class="card-header">
                <h1>Welcome back</h1>
                <p>Sign in to your account to continue</p>
            </div>
            <div class="card-body">

                <%
                    String errorParam = request.getParameter("error");
                    String errorMsg = (String) request.getAttribute("loginError");
                    if ("1".equals(errorParam)) errorMsg = "Invalid username or password. Please try again.";
                    if ("2".equals(errorParam)) errorMsg = "Database error. Please contact administrator.";
                    if (errorMsg != null) {
                %>
                <div class="error-msg">⚠️ <%= errorMsg %></div>
                <% } %>

                <form method="post" action="loginaction.jsp">
                    <div class="form-group">
                        <label class="form-label" for="username">Username</label>
                        <input type="text" id="username" name="username"
                               class="form-control" placeholder="Enter your username" required autocomplete="username">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="password">Password</label>
                        <input type="password" id="password" name="password"
                               class="form-control" placeholder="Enter your password" required autocomplete="current-password">
                    </div>

                    <button type="submit" class="btn-login">Sign In →</button>
                </form>

                <div class="divider"><span>New to EduQR?</span></div>
                <a href="register.jsp" class="register-link">📝 Create an account</a>

            </div>
        </div>
    </div>
</body>
</html>