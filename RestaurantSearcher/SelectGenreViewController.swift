//
//  SelectGenreViewController.swift
//  RestaurantSearcher
//
//  Created by YoNa on 2021/05/08.
//

import UIKit

// Barボタン用の変数
var clearButtonItem : UIBarButtonItem!

class SelectGenreViewController: UIViewController {
    
    struct GenreCheck {
        var code:String
        var title : String
        var isMarked : Bool
    }
    // 検索画面から受け取ったジャンルリスト
    var genreList : [(
        code : String, // ジャンルコード
        name : String  // ジャンル名
    )] = []

    // ジャンル
    var genres = [GenreCheck]()


    @IBOutlet weak var genreListTableView: UITableView!
    @IBOutlet weak var decisionButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        for count in 0..<self.genreList.count {
            genres.append(contentsOf: [GenreCheck(code: genreList[count].code, title: genreList[count].name, isMarked: false)])
        }
        // クリアボタン設定
        clearButtonItem = UIBarButtonItem(title: "クリア", style: .plain, target: self, action: #selector(clearButtonPressed(_:)))

        // クリアボタン追加
        self.navigationItem.rightBarButtonItem = clearButtonItem

        decisionButton.layer.cornerRadius = 5
        genreListTableView.dataSource = self
        genreListTableView.delegate = self
    }
    // MARK:- アクション
    // クリアボタン
    @objc func clearButtonPressed(_ sender: UIBarButtonItem) {
        let genreCount = genres.count - 1
        for count in 0...genreCount {
            var genre = genres[count]
            genre.isMarked = false

            genres.remove(at: count)
            genres.insert(genre, at: count)
        }
        genreListTableView.reloadData()
     }
    // 決定ボタン
    @IBAction func TapdecisionButton(_ sender: Any) {
        let nav = self.navigationController
        // 一つ前のViewControllerを取得する
        let viewController = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! ViewController
        // 一つ前の画面に選択したジャンル情報を渡す
        viewController.selectGenres = self.genres
        // 検索画面に遷移
        self.navigationController?.popViewController(animated: true)

    }
}

// MARK:- ジャンルTableView関連
extension SelectGenreViewController: UITableViewDataSource,UITableViewDelegate {
    // section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // セル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres.count
    }
    // セル表示内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = genreListTableView.dequeueReusableCell(withIdentifier: "genreCell", for:indexPath) as! GenreListTableViewCell
        let genre = genres[indexPath.row]

        cell.genreNameLabel.text = genre.title
        cell.checkmarkImageView.image = genre.isMarked == true ? UIImage(named: "checkicon") : UIImage(named: "uncheckicon")

        return cell
    }
    // タップ時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated:true)
        guard let cell = tableView.cellForRow(at: indexPath) as? GenreListTableViewCell else { return }
        var genre = genres[indexPath.row]
        genre.isMarked = !genre.isMarked
        genres.remove(at: indexPath.row)
        genres.insert(genre, at: indexPath.row)

        cell.checkmarkImageView.image = genre.isMarked == true ? UIImage(named: "checkicon") : UIImage(named: "uncheckicon")
    }

}
