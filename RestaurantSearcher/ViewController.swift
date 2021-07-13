//
//  ViewController.swift
//  RestaurantSearcher
//
//  Created by YoNa on 2021/05/06.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    // 位置情報関連変数
    // 緯度
    var latitudeNow: String = ""
    // 経度
    var longitudeNow: String = ""
    // 現在位置取得ボタンを押したかどうかの判定変数
    var getNowLocationButtonFlag : Int = 0
    /**
     検索ボタンを有効にするための変数、
     検索範囲だけでなく、位置を取得することも条件とする。
     未取得：0／取得済み：1
     */
    var getNowLocationFlag : Int = 0
    var selectionRangeFlag : Int = 0
    
    
    // 検索範囲pickerView表示内容
    let ranges = ["~300m以内" , "~500m以内" , "~1,000m以内" , "~2,000m以内" , "~3,000m以内"]
    // 検索範囲をAPIのURLのパラメータにするためのもの
    let rangeParameters = ["1","2","3","4","5"]
    // 選択された検索範囲API用変数
    var selectRangeParameter : String?
    
    // レストランのAPIかジャンルのAPIか判定変数
    // YES：1／NO：0
    var getGenreListFalg : Int = 0
    var getRestaurantListFalg : Int = 0
    
    // JSONから取得したレストラン情報
    var results_returned : String = "" // 取得件数
    // 検索結果画面にも送る。
    // レストラン配列
    var shopList : [(
        id : String , // レストランID
        name : String , // レストラン名
        address : String , // 住所
        mobile_access : String , // 交通アクセス
        code : String, // ジャンルコード
        genreName : String,  // ジャンル名
        photo : String , // レストランの写真
        open : String , // 営業時間
        close : String , // 定休日
        catch : String , // お店キャッチ
        budget : String , // 平均予算
        latitude : Double , // 緯度
        longitude : Double // 経度
    )] = []
    
    
    // MARK:- レストラン構造体
    // JSONのジャンル内のデータ構造
    struct RestrantGenre : Codable {
        var code : String?  // ジャンルコード
        var name : String?  // ジャンル名
    }
    // JSONのphoto内のデータ構造
    struct Photo : Codable {
        var pc : PC?  // 携帯用画像
    }
    // JSONのphoto内のデータ構造
    struct PC : Codable {
        var l : String?  // 携帯用画像L
    }
    // JSONのbudget内のデータ構造
    struct Budget : Codable {
        var average : String?  // 平均予算
    }
    // JSONのshop内のデータ構造
    struct Shop : Codable {
        var id : String?  // レストランID
        var name : String?  // レストラン名
        var address : String?  // 住所
        var mobile_access : String?  // 交通アクセス
        var genre : RestrantGenre?  // ジャンル
        var photo : Photo?  // レストランの写真
        var open : String?  // 営業時間
        var close : String?  // 定休日
        var `catch` : String?  // お店キャッチ
        var budget : Budget?  // 平均予算
        var lat : Double?  // 緯度
        var lng : Double?// 経度
    }
    // JSONのデータ構造
    struct ShopJson:Codable {
        let shop : [Shop]?
        let results_returned : String?
    }
    
    // JSONのデータ構造
    struct RestanrantResultJson:Codable {
        let results : ShopJson?
    }
    
    // MARK:- ジャンルリスト構造体
    struct Genre:Codable {
        let code : String?
        let name : String?
    }
    struct GenreJson:Codable {
        let genre : [Genre]?
    }
    struct GenreResultJson:Codable {
        let results : GenreJson?
    }
    // APIで取得する
    var genreList : [(
        code : String, // ジャンルコード
        name : String  // ジャンル名
    )] = []
    // ジャンル選択画面から受け取る選択されたジャンル
    var selectGenres = [SelectGenreViewController.GenreCheck]()
    // ジャンルを含めた検索の作成用
    var selectGenreList : String = ""
    // 選択されたジャンルがあるかどうかの判定
    // ない：０／ある：１
    var selectGenreFlag : Int = 0
    
    
    var locationManager =  CLLocationManager()
    
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var nowLocationButton: UIButton!
    @IBOutlet weak var selectRangeTextField: UITextField!
    @IBOutlet weak var selectGenreButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet var selectGenreLabel: UILabel!
    
    var pickerView: UIPickerView = UIPickerView()
    
    
    // 結果画面に送る用のもの
    var searchConditions = [
        "range": "",
        "genre": ""
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // ロケーションマネージャのセットアップ
        setupLocationManager()
        
        // ジャンルリスト取得
        getGenreList()
        
        // 最初検索ボタンを非活性化しておく
        searchButton.isEnabled = false
        searchButton.backgroundColor = UIColor.gray
        // MARK:- NavigationBar関連
        // pickerView生成
        createPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        // MARK:- NavigationBar関連
        // 戻るボタンの文字削除
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        // MARK:- デザイン
        locationMapView.layer.cornerRadius = 5
        
        
        nowLocationButton.layer.cornerRadius = 5
        selectRangeTextField.layer.cornerRadius = 5
        
        searchButton.layer.cornerRadius = 5
        selectRangeTextField.layer.borderWidth = 1
        selectRangeTextField.layer.borderColor = UIColor(red: 255/255, green: 119/255, blue: 70/255, alpha: 1.0).cgColor
        
        selectGenreButton.layer.cornerRadius = 5
    }
    // MARK: - 選択したジャンルを画面に表示
    // 選択したジャンルを画面に表示、クエリ作成変数に格納
    override func viewDidAppear(_ animated: Bool) {
        if selectGenres.count != 0{
            selectGenreFlag = 1
        }
        /**
         選択されたジャンルは選択されたものだけではないので
         選択されたものを探し、ジャンルを含めた検索に使えるようにコードだけ抽出
         検索画面に反映、結果画面に使うようにジャンル名も抽出
         */
        // 選択されたジャンルのコード
        var selectGenreCode : [String] = []
        // 選択されたジャンル名
        var selectGenreTitle : [String] = []
        // ジャンル選択画面から帰ってきたものから選択済みのものを数える
        var selectGenreCount : Int = 0
        for count in 0..<selectGenres.count {
            if selectGenres[count].isMarked {
                selectGenreCount += 1
                // 選択されたジャンルのコードと名前だけ取り出す
                selectGenreCode.append(selectGenres[count].code)
                selectGenreTitle.append(selectGenres[count].title)
            }
        }
        
        // ジャンル関連
        if selectGenreCode.count != 0 {
            // 選択ジャンル1つ
            if selectGenreCode.count == 1 {
                selectGenreLabel.text! = selectGenreTitle[0]
                selectGenreList = selectGenreCode[0]
            } else {
                for count in 0..<selectGenreCode.count{
                    if count == 0 {
                        // 選択したジャンル名１つ反映
                        selectGenreLabel.text! = selectGenreTitle[count]
                    } else {
                        // 選択したジャンル名複数反映
                        selectGenreLabel.text! += " , \(selectGenreTitle[count])"
                        
                        selectGenreList += ",\(selectGenreCode[count])"
                    }
                }
            }
        }
    }
    
    // MARK: - アクション
    // 現在地取得タップ
    @IBAction func getNowLocationButton(_ sender: Any) {
        // 位置情報取得時にアラートを表示するための判定変数
        getNowLocationButtonFlag = 1
        
        let status = locationManager.authorizationStatus
        // 位置情報取得拒否でアラート表示
        if status == .denied {
            showLocationDeniedAlert()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            // 位置情報更新開始
            locationManager.startUpdatingLocation()
        }
    }
    // ジャンルテキストフィールドタップ
    @IBAction func selectGenreButton(_ sender: Any) {
        
        let selectGenreViewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectGenreViewController") as! SelectGenreViewController
        // 選択されたジャンルがある場合は選択画面から帰ってきたものをそのまま渡す
        if selectGenreFlag == 0 {
            selectGenreViewController.genreList = self.genreList
        }else{
            selectGenreViewController.genres = self.selectGenres
        }
        
        // ジャンル選択画面に遷移
        self.navigationController?.pushViewController(selectGenreViewController, animated: true)
        
    }
    // 検索タップ
    @IBAction func tapSearchButton(_ sender: Any) {
        getRestaurantListFalg = 1
        // 結果外面に表示するジャンル取得
        searchConditions["genre"] = selectGenreLabel.text
        getJSON()
        
    }
    // MARK:-pickerView関連
    func createPickerView()  {
        pickerView.delegate = self
        // UITextField が持つ inputView に pickerView を設定
        selectRangeTextField.inputView = pickerView
        // ツールバー
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        // 完了ボタン
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.donePicker))
        toolbar.items = [spacer,doneButtonItem]
        selectRangeTextField.inputAccessoryView = toolbar
    }
    // 完了ボタンでキーボードを閉じる
    @objc func donePicker() {
        
        selectRangeTextField.endEditing(true)
        // pickerViewを開いてすぐ閉じると一番目が反映されない
        selectRangeTextField.text = "\(ranges[pickerView.selectedRow(inComponent: 0)])"
        searchConditions["range"] = "\(ranges[pickerView.selectedRow(inComponent: 0)])"
        selectionRangeFlag = 1
        // 位置情報も取得して検索ボタンを有効化する
        if getNowLocationFlag == 1 {
            enableSearchButton()
        }
    }
    // キーボード以外タップでキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let selectRangeText = selectRangeTextField.text
        if selectRangeText != "" {
            selectionRangeFlag = 1
            enableSearchButton()
        }
        selectRangeTextField.endEditing(true)
    }
    
    // MARK:- ロケーションマネージャのセットアップ
    func setupLocationManager() {
        
        locationManager = CLLocationManager()
        
        // 権限をリクエスト
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // 位置情報を使用可能か
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK:- 位置情報アラート
    // 位置情報許可なしアラート
    func showLocationDeniedAlert() {
        let alertTitle = "位置情報取得が許可されていません。"
        let alertMessage = "設定アプリの「プライバシー > 位置情報サービス」から変更してください。"
        let alert: UIAlertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle:  UIAlertController.Style.alert
        )
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        // UIAlertController に Action を追加
        alert.addAction(defaultAction)
        // Alertを表示
        present(alert, animated: true, completion: nil)
        
        
    }
    // 取得完了アラート
    func showLocationGetAlert() {
        // 次に進みやすいようにactionSheetにする
        let alert: UIAlertController = UIAlertController(title: "現在地取得完了", message: "現在地の取得が完了しました。", preferredStyle:  UIAlertController.Style.actionSheet)
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(defaultAction)
        // アラートを表示
        present(alert, animated: true, completion: nil)
    }
    
    // MARK:- ジャンルリスト取得
    func getGenreList(){
        getGenreListFalg = 1
        getJSON()
    }
    
    // MARK: - API JSON取得
    func getJSON() {
        // APIKey取得
        let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)
        let api = plist!["api"]!
        
        // ジャンルJSONとレストランJSONで分岐する
        // url生成
        var url = NSURL(string: "")
        if getGenreListFalg == 1 {
            // ジャンル取得APIURL作成
            url = NSURL(string: "https://webservice.recruit.co.jp/hotpepper/genre/v1/?key=\(api)&format=json")
            
        }else{
            // レストラン検索APIURL作成
            
            url = NSURL(string: "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=\(api)&lat=\(latitudeNow)&lng=\(longitudeNow)&range=\(selectRangeParameter ?? "5")&format=json")
            
            // シミュレータ動作確認・家周囲田んぼのみで大阪駅中心
            // url = NSURL(string: "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=\(api)&lat=34.7026000276041&lng=135.49584331429153&range=\(selectRangeParameter ?? "5")&format=json")
            
        }
        // ジャンル選択を追加
        if selectGenreList.count != 0 {
            // URLにジャンルクエリ追加
            var components = URLComponents(url: url! as URL, resolvingAgainstBaseURL: true)
            components?.queryItems! += [URLQueryItem(name: "genre", value: selectGenreList)]
            url = components?.url as NSURL?
            searchConditions["genre"] = selectGenreLabel.text
        }
        let requestUrl = URLRequest(url: url! as URL)
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration,delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: requestUrl,
                                    completionHandler: {
                                        (data, response, error) -> Void in //dataにJSONが入る
                                        //JSON解析の処理
                                        // 解析し配列に格納
                                        do{
                                            
                                            // JSPNDecoderのインスタンス取得
                                            let decoder = JSONDecoder()
                                            /**
                                             ジャンル検索の場合
                                             */
                                            if self.getRestaurantListFalg == 1 {
                                                // レストランAPIのJSON取得
                                                let json = try decoder.decode(RestanrantResultJson.self, from: data!)
                                                
                                                if let shops = json.results?.shop{
                                                    // リストを初期化
                                                    self.shopList.removeAll()
                                                    // 数だけ取得
                                                    for item in shops {
                                                        // レストラン情報をアンラップ
                                                        
                                                        if let id = item.id ,
                                                           let name = item.name,
                                                           let address = item.address,
                                                           let mobile_access  = item.mobile_access,
                                                           let code = item.genre?.code,
                                                           let genreName = item.genre?.name,
                                                           let photo = item.photo?.pc?.l,
                                                           let open = item.open,
                                                           let close = item.close,
                                                           let `catch` = item.catch,
                                                           let budget = item.budget?.average,
                                                           let jsonLatitude = item.lat,
                                                           let jsonLongitude = item.lng{
                                                            // 1つのレストラン情報をタプルでまとめて管理
                                                            
                                                            let shop = (id ,name ,address ,mobile_access  ,code ,genreName ,photo ,open ,close ,`catch`,budget ,jsonLatitude ,jsonLongitude )
                                                            // レストラン配列へ追加
                                                            self.shopList.append(shop)
                                                        }
                                                    }
                                                    
                                                }
                                                
                                                if let returns = json.results?.results_returned{
                                                    self.results_returned = returns
                                                }
                                                // 画面遷移
                                                self.searchResultTransition()
                                                
                                                self.getRestaurantListFalg = 0
                                            } else {
                                                // ジャンルAPIのJSON取得
                                                let json = try decoder.decode(GenreResultJson.self, from: data!)
                                                if let genres = json.results?.genre{
                                                    // リストを初期化
                                                    self.genreList.removeAll()
                                                    // 数だけ取得
                                                    for item in genres {
                                                        // レストラン情報をアンラップ
                                                        if let code = item.code , let name = item.name {
                                                            let genre = (code,name)
                                                            self.genreList.append(genre)
                                                            
                                                        }
                                                    }
                                                    
                                                }
                                                // ジャンルリスト取得完了
                                                self.getGenreListFalg = 0
                                            }
                                            
                                        } catch {
                                            print(error)
                                            print("エラーが発生しました")
                                        }
                                    })
        task.resume() //実行
        
        
        
    }
    // MARK: - 検索結果画面遷移
    func searchResultTransition(){
        // 戻るボタンのタイトルを"戻る"に変更します。
        let searchResultViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchResultViewController") as! SearchResultViewController
        // 検索結果情報を遷移画面へ渡す
        searchResultViewController.shopList = self.shopList
        searchResultViewController.results_returned = self.results_returned
        // 検索条件を渡す
        searchResultViewController.searchConditions = self.searchConditions
        // レストラン一覧画面へ遷移
        self.navigationController?.pushViewController(searchResultViewController, animated: true)
    }
    
    // MARK: - 検索ボタン有効化
    func enableSearchButton(){
        
        searchButton.isEnabled = true
        searchButton.backgroundColor = UIColor(red: 255/255, green: 119/255, blue: 70/255, alpha: 1.0)
    }
}




// MARK:-pickerView関連
extension ViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    
    // pickerView に表示する列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // pickerView に表示するデータの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ranges.count
    }
    // pickerView に設定するデータを登録するための
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ranges[row]
    }
    // pickerView の各種データを選択したときに呼ばれる
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectRangeTextField.text = ranges[row]
        searchConditions["range"] = ranges[row]
        selectRangeParameter = rangeParameters[row]
    }
    
}

// MARK:-位置情報取得関連

extension ViewController : CLLocationManagerDelegate {
    // 現在地の取得した場合
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let location = locations.first
        // MAP表示ようにcoordinateで取り出す
        let coordinate = location?.coordinate
        let latitude = coordinate?.latitude
        let longitude = coordinate?.longitude
        // 位置情報を格納する
        self.latitudeNow = String(latitude!)
        self.longitudeNow = String(longitude!)
        
        // 取得ボタンを押した場合完了アラート表示
        if getNowLocationButtonFlag == 1 {
            showLocationGetAlert()
            // マップに現在地を表示する。
            locationMapView.region = MKCoordinateRegion(center: coordinate!, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
            
            // userLocationを使うと移動中に動いてしまうので画像を被せる
            // 現在地取得ボタン押さないと取得しないイメージがあるため
            var fakeUserLocationImage: CALayer!
            fakeUserLocationImage = CALayer()
            var height = locationMapView.frame.size.height / 2
            height = height - 15
            var width = locationMapView.frame.size.width / 2
            width = width - 15
            
            fakeUserLocationImage.frame = CGRect(x: width, y:height , width: 30, height: 30)
            fakeUserLocationImage.contents = UIImage(named: "userlocationicon")?.cgImage
            fakeUserLocationImage.contentsRect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
            locationMapView.layer.addSublayer(fakeUserLocationImage)
            // 検索範囲も選択済みで検索ボタン有効化
            getNowLocationFlag = 1
            if selectionRangeFlag == 1 {
                enableSearchButton()
            }
            
        }
    }
}
