# NVStream — Hướng dẫn cài đặt trên máy host (Windows + RTX 3070)

Build từ GitHub Actions: https://github.com/vj3tduk0903-source/NVStream/actions

## 1. Lấy file cài đặt

Vào workflow run mới nhất → mục **Artifacts** → tải `build-Windows-AMD64`.

Trong đó có 2 lựa chọn:

| File | Dùng khi nào |
|---|---|
| `NVStream-installer.msi` | Cài đặt chuẩn, tạo shortcut + service tự động. **Khuyến nghị.** |
| `NVStream-lite.zip` | Bản portable, giải nén chạy trực tiếp, không cài service. |

## 2. Cài đặt (bản MSI)

1. Double-click `NVStream-installer.msi`
2. Windows SmartScreen sẽ cảnh báo (file chưa ký số) → **More info** → **Run anyway**
3. Làm theo hướng dẫn, chọn:
   - **Autostart**: bật để NVStream tự chạy khi khởi động máy
   - **Firewall rule**: bật để Moonlight kết nối được từ máy khác
4. Sau khi cài, NVStream chạy ở khay hệ thống (system tray)

## 3. Cấu hình lần đầu

Mở web UI: chuột phải icon khay → **Open NVStream**, hoặc vào `https://localhost:47990`

Đặt **username / password** (dùng để truy cập web UI sau này).

Vào tab **Configuration**:

| Mục | Giá trị khuyến nghị cho RTX 3070 |
|---|---|
| `nvenc_preset` | `p1` (nhanh nhất) hoặc `p4` (cân bằng) |
| `nvenc_twopass` | `quarter_res` |
| `nvenc_rate_control` | `cbr` |
| `video_bitrate` | 20000 (1080p) / 40000 (1440p) |
| `fps` | 60 |
| `encoder` | `nvenc` |
| `hevc_mode` | `1` (nếu client hỗ trợ) — tiết kiệm băng thông ~40% |

## 4. Ghép nối với Moonlight

1. Cài **Moonlight** trên máy client (PC khác / điện thoại / TV box)
2. Moonlight tự dò host trên cùng mạng LAN → chọn **NVStream** (hoặc tên PC)
3. Moonlight hiện mã PIN 4 số
4. Vào web UI NVStream → tab **PIN** → nhập mã → **Send**
5. Quay lại Moonlight, máy host hiện ra → chọn app để stream

Nếu Moonlight không tự dò được: **Add PC manually** → nhập IP máy host.

## 5. Mở firewall nếu cần

Nếu Moonlight không kết nối được, mở các port trên máy host:

```
TCP: 47984, 47989, 48010
UDP: 47998, 47999, 48000, 48002, 48010
```

PowerShell (Admin):
```powershell
New-NetFirewallRule -DisplayName "NVStream" -Direction Inbound -Protocol TCP -LocalPort 47984,47989,48010 -Action Allow
New-NetFirewallRule -DisplayName "NVStream-UDP" -Direction Inbound -Protocol UDP -LocalPort 47998,47999,48000,48002,48010 -Action Allow
```

## 6. Gỡ cài đặt

Settings → Apps → **NVStream** → Uninstall.

Gỡ xong, thư mục `C:\Program Files\NVStream` có thể còn config — xóa thủ công nếu muốn sạch hoàn toàn.

---

## Ghi chú kỹ thuật

- **Capture**: DXGI Desktop Duplication (GPU → GPU, zero-copy vào NVENC)
- **Encode**: NVENC hardware (RTX 3070 có NVENC thế hệ 7, hỗ trợ H.264/HEVC/AV1)
- **NVFBC**: KHÔNG dùng được trên RTX 3070 (NVIDIA khoá SDK này cho Quadro/Tesla từ driver 511+)
- **Protocol**: tương thích Moonlight (RTSP + protobuf + TLS), giống GeForce Experience GameStream

### Vì sao không có NVFBC?

NVFBC (NVIDIA Frame Buffer Capture) là API độc quyền chỉ NVIDIA cấp cho dòng Quadro/Tesla/Datacenter.
GeForce consumer (GTX/RTX) bị chặn. Trên RTX 3070, DXGI + NVENC cho độ trễ tương đương
(NVFBC tiết kiệm ~1-2ms nhờ bỏ qua compositor DWM — không đáng kể với streaming LAN).