package stud;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.*;
import javax.imageio.ImageIO;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

@WebServlet("/ShowQRImageServlet")
public class ShowQRImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public ShowQRImageServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String regno = request.getParameter("regno");

        if (regno == null || regno.trim().isEmpty()) {
            response.setContentType("text/plain");
            response.getWriter().write("Please provide a valid regno parameter.");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1521:xe", "system", "system");

            // Fetch both qr_image BLOB and qr_data text in one query
            ps = con.prepareStatement(
                "SELECT qr_image, qr_data, name, branch, mobile, email " +
                "FROM student_qr WHERE regno=?");
            ps.setString(1, regno);
            rs = ps.executeQuery();

            if (rs.next()) {
                Blob blob = rs.getBlob("qr_image");

                if (blob != null && blob.length() > 0) {
                    // CASE 1: BLOB exists — send it directly
                    byte[] imageBytes = blob.getBytes(1, (int) blob.length());
                    response.setContentType("image/png");
                    try (OutputStream out = response.getOutputStream()) {
                        out.write(imageBytes);
                        out.flush();
                    }

                } else {
                    // CASE 2: BLOB is NULL — generate QR on-the-fly from qr_data or columns
                    String qrData = rs.getString("qr_data");

                    if (qrData == null || qrData.trim().isEmpty()) {
                        String name   = rs.getString("name");
                        String branch = rs.getString("branch");
                        String mobile = rs.getString("mobile");
                        String email  = rs.getString("email");
                        qrData = "RegNo: "  + regno +
                                 " | Name: "   + (name   != null ? name   : "") +
                                 " | Branch: " + (branch != null ? branch : "") +
                                 " | Mobile: " + (mobile != null ? mobile : "") +
                                 " | Email: "  + (email  != null ? email  : "");
                    }

                    byte[] imageBytes = generateQRImage(qrData, 250);

                    // Save back to DB so future requests use cached BLOB
                    saveQRImageToDB(con, regno, imageBytes, qrData);

                    response.setContentType("image/png");
                    try (OutputStream out = response.getOutputStream()) {
                        out.write(imageBytes);
                        out.flush();
                    }
                }

            } else {
                response.setContentType("text/plain");
                response.getWriter().write("No record found with RegNo: " + regno);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/plain");
            response.getWriter().write("Error: " + e.getMessage());
        } finally {
            try { if (rs  != null) rs.close();  } catch (Exception ex) {}
            try { if (ps  != null) ps.close();  } catch (Exception ex) {}
            try { if (con != null) con.close(); } catch (Exception ex) {}
        }
    }

    // Generate QR code PNG as byte array
    private byte[] generateQRImage(String qrText, int size) throws Exception {
        QRCodeWriter writer = new QRCodeWriter();
        BitMatrix matrix = writer.encode(qrText, BarcodeFormat.QR_CODE, size, size);

        BufferedImage image = new BufferedImage(size, size, BufferedImage.TYPE_INT_RGB);
        for (int x = 0; x < size; x++) {
            for (int y = 0; y < size; y++) {
                image.setRGB(x, y, matrix.get(x, y) ? 0xFF000000 : 0xFFFFFFFF);
            }
        }

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "png", baos);
        return baos.toByteArray();
    }

    // Save generated QR image back to DB (caches it for future requests)
    private void saveQRImageToDB(Connection con, String regno,
                                  byte[] imageBytes, String qrData) {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE student_qr SET qr_image=?, qr_data=? WHERE regno=?")) {
            ps.setBytes(1, imageBytes);
            ps.setString(2, qrData);
            ps.setString(3, regno);
            ps.executeUpdate();
        } catch (Exception e) {
            System.err.println("Warning: Could not save QR to DB for " + regno + ": " + e.getMessage());
        }
    }
}