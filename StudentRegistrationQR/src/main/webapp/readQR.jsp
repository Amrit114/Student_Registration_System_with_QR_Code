<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String user = (String)session.getAttribute("username");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scan QR Code — EduQR</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/html5-qrcode/html5-qrcode.min.js"></script>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root { --ink:#0d1117; --paper:#f5f0e8; --accent:#e8490f; --muted:#6b7280; --border:#e2d9cc; --sidebar-w:240px; }
        body { font-family: 'DM Sans', sans-serif; background: var(--paper); }

        .sidebar { position: fixed; left: 0; top: 0; bottom: 0; width: var(--sidebar-w); background: var(--ink); color: #fff; display: flex; flex-direction: column; z-index: 50; }
        .sidebar-brand { padding: 28px 24px 20px; border-bottom: 1px solid rgba(255,255,255,.08); }
        .sidebar-brand-name { font-family: 'Syne', sans-serif; font-size: 1.3rem; font-weight: 800; }
        .sidebar-brand-name span { color: var(--accent); }
        .sidebar-brand-role { font-size: 0.72rem; color: rgba(255,255,255,.4); text-transform: uppercase; letter-spacing: 1.5px; margin-top: 4px; }
        .sidebar-nav { flex: 1; padding: 16px 0; }
        .nav-section-label { font-size: 0.65rem; font-weight: 600; text-transform: uppercase; letter-spacing: 2px; color: rgba(255,255,255,.25); padding: 16px 24px 8px; }
        .nav-item { display: flex; align-items: center; gap: 12px; padding: 11px 24px; color: rgba(255,255,255,.65); text-decoration: none; font-size: 0.9rem; transition: background .15s; border-left: 3px solid transparent; }
        .nav-item:hover, .nav-item.active { background: rgba(255,255,255,.06); color: #fff; border-left-color: var(--accent); }
        .nav-icon { font-size: 1rem; width: 20px; text-align: center; }
        .sidebar-user { padding: 16px 24px; border-top: 1px solid rgba(255,255,255,.08); font-size: 0.82rem; color: rgba(255,255,255,.5); }
        .sidebar-user strong { color: #fff; display: block; }

        .main { margin-left: var(--sidebar-w); padding: 36px; display: flex; flex-direction: column; align-items: center; }
        .page-header { width: 100%; max-width: 520px; margin-bottom: 28px; }
        .page-header h1 { font-family: 'Syne', sans-serif; font-size: 1.8rem; font-weight: 800; letter-spacing: -1px; }
        .page-header p { color: var(--muted); font-size: 0.9rem; margin-top: 4px; }

        /* Scanner */
        .scanner-card {
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 16px; overflow: hidden;
            width: 100%; max-width: 520px; margin-bottom: 20px;
        }
        .scanner-header {
            background: var(--ink); padding: 18px 24px;
        }
        .scanner-header h3 {
            font-family: 'Syne', sans-serif; font-size: 1rem; font-weight: 700; color: #fff;
        }
        .scanner-header p { font-size: 0.82rem; color: rgba(255,255,255,.5); margin-top: 2px; }
        .scanner-body { padding: 20px; }
        #reader { border-radius: 8px; overflow: hidden; }

        /* Status */
        .scan-status {
            padding: 14px 16px; border-radius: 8px;
            font-size: 0.875rem; font-weight: 500;
            margin-top: 12px; text-align: center;
            display: none;
        }
        .scan-status.show { display: block; }
        .scan-status.success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }
        .scan-status.error   { background: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; }

        /* Result card */
        .result-card {
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 16px; width: 100%; max-width: 520px;
            overflow: hidden; display: none;
        }
        .result-card.show { display: block; }
        .result-card-header {
            background: var(--accent); padding: 18px 24px;
        }
        .result-card-header h3 {
            font-family: 'Syne', sans-serif; font-size: 1rem; font-weight: 700; color: #fff;
        }
        .result-card-body { padding: 0; }
        .result-card-body table { width: 100%; border-collapse: collapse; }
        .result-card-body td { padding: 13px 20px; border-bottom: 1px solid var(--border); font-size: 0.88rem; }
        .result-card-body td:first-child { color: var(--muted); font-weight: 500; font-size: 0.8rem; width: 36%; }
        .result-card-body tr:last-child td { border-bottom: none; }
        .result-qr { text-align: center; padding: 20px; border-top: 1px solid var(--border); }
        .result-qr img { width: 110px; height: 110px; border: 2px solid var(--border); border-radius: 8px; padding: 6px; }

        .btn-scan-again {
            width: 100%; max-width: 520px; padding: 13px;
            background: var(--ink); color: #fff; border: none; border-radius: 10px;
            font-family: 'Syne', sans-serif; font-size: 0.95rem; font-weight: 700;
            cursor: pointer; margin-top: 16px; transition: background .2s;
        }
        .btn-scan-again:hover { background: #1c2733; }
    </style>
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="sidebar-brand-name">Edu<span>QR</span></div>
            <div class="sidebar-brand-role">
                <%= "ADMIN".equalsIgnoreCase((String)session.getAttribute("role")) ? "Admin Panel" : "Student Portal" %>
            </div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section-label">Navigation</div>
            <% if ("ADMIN".equalsIgnoreCase((String)session.getAttribute("role"))) { %>
            <a href="adminDashbord.jsp" class="nav-item"><span class="nav-icon">📊</span> Dashboard</a>
            <a href="reg.jsp" class="nav-item"><span class="nav-icon">📝</span> Register Student</a>
            <a href="manageStudent.jsp" class="nav-item"><span class="nav-icon">👨‍🎓</span> Manage Students</a>
            <a href="viewStudent.jsp" class="nav-item"><span class="nav-icon">🔍</span> View Students</a>
            <a href="printID.jsp" class="nav-item"><span class="nav-icon">🖨️</span> Print ID Cards</a>
            <% } %>
            <a href="readQR.jsp" class="nav-item active"><span class="nav-icon">📷</span> Scan QR Code</a>
        </nav>
        <div class="sidebar-user">
            <strong><%= user %></strong>
            <a href="logout.jsp" style="color:rgba(255,255,255,.4);text-decoration:none;font-size:0.8rem;">🚪 Logout</a>
        </div>
    </aside>

    <main class="main">
        <div class="page-header">
            <h1>QR Scanner</h1>
            <p>Point your camera at a student QR code to view their details</p>
        </div>

        <div class="scanner-card">
            <div class="scanner-header">
                <h3>📷 Camera Scanner</h3>
                <p>Allow camera access when prompted</p>
            </div>
            <div class="scanner-body">
                <div id="reader"></div>
                <div id="scanStatus" class="scan-status"></div>
            </div>
        </div>

        <div id="resultCard" class="result-card">
            <div class="result-card-header">
                <h3>✅ Student Found</h3>
            </div>
            <div class="result-card-body" id="resultBody"></div>
        </div>

        <button class="btn-scan-again" id="scanAgainBtn" style="display:none;" onclick="resetScanner()">
            🔄 Scan Another QR Code
        </button>
    </main>

    <script>
        const html5QrCode = new Html5Qrcode("reader");
        let scanning = true;

        function speak(text) {
            if ('speechSynthesis' in window) {
                const msg = new SpeechSynthesisUtterance(text);
                msg.lang = "en-IN";
                window.speechSynthesis.speak(msg);
            }
        }

        function showStatus(msg, type) {
            const el = document.getElementById('scanStatus');
            el.textContent = msg;
            el.className = 'scan-status show ' + type;
        }

        function onScanSuccess(decodedText) {
            if (!scanning) return;
            scanning = false;

            html5QrCode.stop().catch(err => {});
            showStatus('✅ QR Code scanned! Fetching student details...', 'success');

            let regMatch = decodedText.match(/RegNo:\s*(\S+)/i);
            let regno = regMatch ? regMatch[1] : decodedText.trim();

            fetch("getStudent.jsp?regno=" + encodeURIComponent(regno))
                .then(res => res.text())
                .then(data => {
                    document.getElementById('resultBody').innerHTML = data;
                    document.getElementById('resultCard').classList.add('show');
                    document.getElementById('scanAgainBtn').style.display = 'block';

                    const plainText = document.getElementById('resultBody').innerText;
                    speak("Welcome! " + plainText + " Thank you.");
                })
                .catch(() => {
                    showStatus('❌ Failed to fetch student details. Please try again.', 'error');
                    speak("Error fetching student details");
                    scanning = true;
                    startScanner();
                });
        }

        function startScanner() {
            Html5Qrcode.getCameras().then(cameras => {
                if (cameras && cameras.length) {
                    html5QrCode.start(cameras[0].id, { fps: 10, qrbox: 220 }, onScanSuccess)
                        .catch(err => showStatus('Camera error: ' + err, 'error'));
                } else {
                    showStatus('No camera found. Please connect a camera.', 'error');
                }
            }).catch(err => showStatus('Camera permission denied: ' + err, 'error'));
        }

        function resetScanner() {
            scanning = true;
            document.getElementById('resultCard').classList.remove('show');
            document.getElementById('resultBody').innerHTML = '';
            document.getElementById('scanAgainBtn').style.display = 'none';
            document.getElementById('scanStatus').className = 'scan-status';
            startScanner();
        }

        startScanner();
    </script>
</body>
</html>