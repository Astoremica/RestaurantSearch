//
//  RestaurantDetailViewController.swift
//  RestaurantSearcher
//
//  Created by YoNa on 2021/05/10.
//

import UIKit
import MapKit

class RestaurantDetailViewController: UIViewController {
    
    
    // タップされた
    var results_returned : String = "" // 取得件数
    var shopList : (
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
    )!
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var catchCopyLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closeLabel: UILabel!
    
    @IBOutlet weak var restaurantLocationMapView: MKMapView!
    
    // マップでの経路表示
    @IBOutlet weak var toMapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // NavigarionBar タイトルに店名を
        self.navigationItem.title = shopList.name
        
        setRestaurantDetail()
        
        // デザイン
        setLayout()
        
    }
    
    // MARK:- マップでの経路表示
    func setRestaurantDetail() {
        restaurantImageView.downloaded(from: shopList.photo)
        restaurantNameLabel.text = shopList.name
        restaurantNameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        genreLabel.text = shopList.genreName
        budgetLabel.text = shopList.budget
        //        budgetLabel.sizeToFit()
        budgetLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        accessLabel.text   = shopList.mobile_access
        //        accessLabel.sizeToFit()
        accessLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        catchCopyLabel.text = shopList.catch
        //        catchCopyLabel.sizeToFit()
        catchCopyLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        addressLabel.text = shopList.address
        //        addressLabel.sizeToFit()
        addressLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        openLabel.text = shopList.open
        openLabel.sizeToFit()
        openLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        closeLabel.text = shopList.close
        //        closeLabel.sizeToFit()
        closeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        // マップ表示
        setRestaurantMap(latitude: shopList.latitude, longitude: shopList.longitude)
    }
    
    // MARK:- 区切り線生成
    func setLayout() {
        toMapButton.layer.cornerRadius = 5
        // 区切り線を引く。
        // キャッチ下
//        let catchLineView = createUnderLine(height: Double(catchCopyLabel.bounds.size.height),minus : -20)
//        catchCopyLabel.addSubview(catchLineView)
//        // マップ下
//        var height = restaurantLocationMapView.bounds.size.height
//        height += addressLabel.bounds.size.height
//        height += 10
//        let mapLineView = createUnderLine(height: Double(height) ,minus : -50)
//        addressLabel.addSubview(mapLineView)
//        // 営業日した
//        let openLineView = createUnderLine(height: Double(openLabel.bounds.size.height), minus: -39)
//        openLabel.addSubview(openLineView)
        
    }
    // MARK:- 区切り線生成
//    func createUnderLine(height : Double , minus : Double) -> UIView {
//        
//        // 線
//        let line = UIView()
//        var varHeight = height
//        varHeight += 10
//        let width = Double(view.bounds.size.width)
//        line.frame = CGRect(x: minus, y:varHeight , width: width, height: 0.5)
//        line.layer.contentsRect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
//        line.layer.backgroundColor = UIColor.gray.cgColor
//        
//        return line
//        
//    }

    // MARK: - 最初の１つをマップの中央に表示しておく
    func setRestaurantMap(latitude : Double,longitude : Double) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //表示範囲
        // ピンを生成
        let pin = MKPointAnnotation()
         // ピンのタイトル・サブタイトルをセット
        pin.title = shopList.name
        //中心座標と表示範囲をマップに登録する。
        pin.coordinate = center
        restaurantLocationMapView.addAnnotation(pin)
        restaurantLocationMapView.region = MKCoordinateRegion(center: center, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
    }
    // MARK:- マップでの経路表示
    @IBAction func toMapButton(_ sender: Any) {
        let daddr = NSString(format: "%f,%f", shopList.latitude, shopList.longitude)
        let urlString = "http://maps.apple.com/?daddr=\(daddr)&dirflg=w"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
}

