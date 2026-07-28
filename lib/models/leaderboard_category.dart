/// Peshqadamlar (Leaderboard) kategoriyalari
///
/// Foydalanuvchilar turli mezonlar bo'yicha reytingni ko'rishlari mumkin:
/// - [bnTiyin] - BN-Tiyin (o'yinlardan toplangan yulduzlar)
/// - [lesen] - Lesen testlari (barcha teillar umumiy %)
/// - [horen] - Hören testlari (barcha teillar umumiy %)
/// - [mockTest] - Mock test (o'rtacha ball)
/// - [attendance] - Davomat (foiz)
enum LeaderboardCategory {
  /// BN-Tiyin (o'yinlardan toplangan yulduzlar) bo'yicha reyting
  bnTiyin,

  /// Lesen testlari (barcha teillar umumiy %) bo'yicha reyting
  lesen,

  /// Hören testlari (barcha teillar umumiy %) bo'yicha reyting
  horen,

  /// Mock test (o'rtacha ball) bo'yicha reyting
  mockTest,

  /// Davomat bo'yicha reyting
  /// O'quvchilarning darsga qatnashish foizi bo'yicha tartiblangan ro'yxat
  attendance,
}
