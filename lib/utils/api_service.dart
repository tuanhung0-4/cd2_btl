// File này sẽ chứa các hàm gọi API backend (nếu có)
// Hiện tại sẽ để mock data cho phát triển UI

class ApiService {
  // Lấy danh sách cà phê mẫu
  static List<Map<String, dynamic>> getCoffeeList() {
    return [
      {
        'name': 'Frappuccino',
        'imageUrl': 'https://i.imgur.com/Frappuccino.png',
        'price': 400,
      },
      {
        'name': 'Iced Latte',
        'imageUrl': 'https://i.imgur.com/IcedLatte.png',
        'price': 250,
      },
      {
        'name': 'Cold Brew',
        'imageUrl': 'https://i.imgur.com/ColdBrew.png',
        'price': 280,
      },
    ];
  }
}

