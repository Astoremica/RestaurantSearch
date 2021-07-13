//
//  SearchResultViewController.swift
//  RestaurantSearcher
//
//  Created by YoNa on 2021/05/08.
//

import UIKit
import MapKit
import UPCarouselFlowLayout

class SearchResultViewController: UIViewController{
    
    // JSONで取得したレストラン情報
    var results_returned : String = "" // 取得件数
    
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
    
    // 設定した検索条件
    var searchConditions = [
        "range": "",
        "genre": ""
    ]
    @IBOutlet weak var searchReasultMapView: MKMapView!
    @IBOutlet weak var restaurantListCollectionView: UICollectionView!
    @IBOutlet weak var searchChangeButton: UIButton!
    @IBOutlet weak var selectRangeLabel: UILabel!
    @IBOutlet weak var selectGenreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: -　NavigationBar関連
        // 戻るボタンの文字削除
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationController?.navigationBar.isTranslucent = false
        // 結果取得数表示
        self.navigationItem.titleView = setTitle(title: "検索結果", subtitle: "\(results_returned)件")
        
        // 結果があれば最初の１件をマップの中央にしておく
        if shopList.count != 0 {
            setRestaurantMap(latitude: shopList[0].latitude, longitude: shopList[0].longitude)
        }
        
        
        // MARK: - レストラン一覧
        restaurantListCollectionView.register(UINib(nibName: "RestaurantListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "restaurantListCell")
        
        let floawLayout = UPCarouselFlowLayout()
        floawLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 42.0, height: restaurantListCollectionView.frame.size.height - 10.0)
        floawLayout.scrollDirection = .horizontal
        // 横アイテムサイズ
        floawLayout.sideItemScale = 1.0
        floawLayout.sideItemAlpha = 1.0
        
        floawLayout.spacingMode = .fixed(spacing: 10.0)
        
        restaurantListCollectionView.collectionViewLayout = floawLayout
        
        restaurantListCollectionView.dataSource = self
        restaurantListCollectionView.delegate = self
        
        // MARK: - 検索条件を反映
        selectRangeLabel.text = searchConditions["range"]
        selectGenreLabel.text = searchConditions["genre"]
        
        // MARK: - デザイン
        searchChangeButton.layer.cornerRadius = 5
    }
    // MARK: - 最初の１つをマップの中央に表示しておく
    func setRestaurantMap(latitude : Double,longitude : Double) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //表示範囲
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        // ピンを生成
        let pin = MKPointAnnotation()
         // ピンのタイトル・サブタイトルをセット
        pin.title = shopList[currentPage].name
        //中心座標と表示範囲をマップに登録する。
        pin.coordinate = center
        searchReasultMapView.addAnnotation(pin)
        let region = MKCoordinateRegion(center: center, span: span)
        searchReasultMapView.setRegion(region, animated:true)
    }
    // MARK: -タイトルにサブタイトル追加
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.gray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        return titleView
    }
    
    // MARK: - 検索画面に戻る
    @IBAction func changeSearchButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - レストランリストスクロール
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.restaurantListCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    fileprivate var currentPage: Int = 0 {
        didSet {
            // マップ連動させる
            setRestaurantMap(latitude: shopList[currentPage].latitude, longitude: shopList[currentPage].longitude)
            
        }
    }
    fileprivate var pageSize: CGSize {
        let layout = self.restaurantListCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
}

// MARK: -レストランリスト
extension SearchResultViewController : UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopList.count
    }
    // セル内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "restaurantListCell", for: indexPath)as! RestaurantListCollectionViewCell
        // セル表示内容
        cell.thumbnailImageView.downloaded(from: shopList[indexPath.row].photo)
        cell.restaurantNameLabel.text = shopList[indexPath.row].name
        cell.genreNameLabel.text = shopList[indexPath.row].genreName
        cell.openLabel.text = shopList[indexPath.row].open
        cell.closeLabel.text = shopList[indexPath.row].close
        cell.accessLabel.text = shopList[indexPath.row].mobile_access
        // セルデザイン
        cell.layer.cornerRadius = 5
        return cell
    }
    // セルタップ
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let restrantDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as! RestaurantDetailViewController
        // 検索結果情報を遷移画面へ渡す
        restrantDetailViewController.shopList = self.shopList[indexPath.row]
        
        restrantDetailViewController.results_returned = self.results_returned
        // 検索した事柄を遷移画面へ渡す
        // レストラン一覧画面へ遷移
        self.navigationController?.pushViewController(restrantDetailViewController, animated: true)
    }
    
}
