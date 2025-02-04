## Website Tạo Lì Xì Trực Tuyến Ứng Dụng Blockchain

### Tổng quan

Website cho phép người dùng tạo và nhận Lì Xì trực tuyến thông qua các nhiệm vụ, sự kiện đặc biệt, hoặc gửi trực tiếp cho người thân, bạn bè. Ứng dụng sử dụng công nghệ Blockchain để đảm bảo tính minh bạch, bảo mật. Người dùng có thể tham gia vào các sự kiện lì xì hoặc tự tạo phong bao lì xì để gửi cho người khác.

### Tính năng chính

1. **Thời gian diễn ra sự kiện Lì Xì**
   - Sự kiện thường được tổ chức vào các dịp lễ lớn như Tết Nguyên Đán, Trung Thu, hoặc các dịp kỷ niệm đặc biệt.
   - Người tạo lì xì có thể tự thiết lập thời gian diễn ra sự kiện (ngày bắt đầu và kết thúc).

2. **Cách tham gia nhận Lì Xì**
   - Người nhận lì xì:
     - Quét mã QR từ phong bao lì xì được tạo bởi chủ lì xì.
     - Nhấp vào liên kết (link) được chia sẻ trực tiếp.
   - Người nhận có thể là:
     - Bất kỳ ai có mã QR hoặc liên kết (tùy chọn mở rộng).
     - Chỉ định người nhận cụ thể thông qua địa chỉ ví Blockchain (tùy chọn riêng tư).
   - Tài khoản nhận: Tiền lì xì sẽ được chuyển trực tiếp vào ví Blockchain của người nhận.

3. **Giá trị giải thưởng**
   - Tổng số lượng bao lì xì và giá trị tiền lì xì do chủ lì xì quy định.
   - Cách phân phối tiền lì xì:
     - Chia đều giá trị cho tất cả các bao lì xì.
     - Phân phối ngẫu nhiên (mỗi bao lì xì có giá trị khác nhau).
   - Đơn vị tiền tệ: Sử dụng tiền mã hóa (ví dụ: ETH, BNB) hoặc token riêng của nền tảng.

4. **Lời chúc và NFT độc đáo**
   - Lời chúc cá nhân hóa:
     - Chủ lì xì có thể nhập lời chúc tùy chỉnh để gửi kèm phong bao lì xì.

5. **Cơ chế bảo mật và minh bạch**
   - Blockchain đảm bảo:
     - Tính minh bạch: Mọi giao dịch lì xì được ghi lại trên Blockchain, không thể thay đổi.
     - Bảo mật: Thông tin người dùng và giao dịch được bảo vệ bằng công nghệ mã hóa.
   - Hợp đồng thông minh (Smart Contract):
     - Tự động hóa quy trình phân phối tiền lì xì.
     - Đảm bảo rằng tiền lì xì chỉ được chuyển khi người nhận quét mã QR hoặc mở phong bao.

### Set up môi trường

1. **Cài đặt Foundry**: Theo hướng dẫn tại https://book.getfoundry.sh/ để cài đặt Foundry.
2. **Clone Repository**: Clone repository này về máy của bạn.
3. **Cài đặt Dependencies**: Chạy `forge install` để cài đặt các dependencies cần thiết.

### Cách chạy project

#### Build

```shell
$ forge build
```

#### Test

```shell
$ forge test
```

#### Format

```shell
$ forge fmt
```

#### Gas Snapshots

```shell
$ forge snapshot
```

#### Anvil

```shell
$ anvil
```

### Command deploy contract

- **Deploy to Anvil**:

```shell
$ make deploy-anvil
```

- **Deploy to Sepolia**:

```shell
$ make deploy-sepolia
```

- **Deploy to Kairos**:

```shell
$ make deploy-kaia
```

### Command test smart contract

```shell
$ forge test
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
