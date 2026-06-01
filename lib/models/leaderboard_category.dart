/// Peshqadamlar (Leaderboard) kategoriyalari
///
/// Foydalanuvchilar turli mezonlar bo'yicha reytingni ko'rishlari mumkin:
/// - [stars] - Yulduzlar bo'yicha reyting
/// - [attendance] - Davomat bo'yicha reyting
/// - [averageScore] - O'rtacha ball bo'yicha reyting
enum LeaderboardCategory {
  /// Yulduzlar bo'yicha reyting
  /// O'quvchilarning umumiy yulduzlar soni bo'yicha tartiblangan ro'yxat
  stars,

  /// Davomat bo'yicha reyting
  /// O'quvchilarning darsga qatnashish foizi bo'yicha tartiblangan ro'yxat
  attendance,

  /// O'rtacha ball bo'yicha reyting
  /// O'quvchilarning uy vazifasi o'rtacha balli bo'yicha tartiblangan ro'yxat
  averageScore,
}
