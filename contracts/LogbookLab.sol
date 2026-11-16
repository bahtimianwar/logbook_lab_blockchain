// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogbookLab {
    struct Peminjaman {
        string namaAlat;
        bytes32 kodePeminjam; // hash NIM, bukan NIM asli
        address wallet;
        uint256 waktuPinjam;
        uint256 waktuKembali; // 0 = belum dikembalikan
    }

    Peminjaman[] private daftar;
    mapping(bytes32 => bool) private sedangDipinjam;

    event AlatDipinjam(uint256 id, string namaAlat, address wallet);
    event AlatDikembalikan(uint256 id);

    function pinjamAlat(string calldata namaAlat, bytes32 kodePeminjam) external {
        require(bytes(namaAlat).length > 0, "Nama alat kosong");
        bytes32 kunci = keccak256(bytes(namaAlat));
        require(!sedangDipinjam[kunci], "Alat sedang dipinjam");

        sedangDipinjam[kunci] = true;
        daftar.push(Peminjaman(namaAlat, kodePeminjam, msg.sender, block.timestamp, 0));
        emit AlatDipinjam(daftar.length - 1, namaAlat, msg.sender);
    }

    function kembalikanAlat(uint256 id) external {
        require(id < daftar.length, "Data tidak ada");
        Peminjaman storage p = daftar[id];
        require(p.wallet == msg.sender, "Bukan peminjam");
        require(p.waktuKembali == 0, "Sudah dikembalikan");

        p.waktuKembali = block.timestamp;
        sedangDipinjam[keccak256(bytes(p.namaAlat))] = false;
        emit AlatDikembalikan(id);
    }

    function jumlahData() external view returns (uint256) {
        return daftar.length;
    }

    function ambilData(uint256 id) external view
        returns (string memory, bytes32, address, uint256, uint256)
    {
        require(id < daftar.length, "Data tidak ada");
        Peminjaman memory p = daftar[id];
        return (p.namaAlat, p.kodePeminjam, p.wallet, p.waktuPinjam, p.waktuKembali);
    }
}