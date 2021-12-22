Spotify APP in swift
===

Tiktok APP 實作練習，目標掌握coding熟悉度，手刻ＵＩ，MVVM架構，OAuth2.0實作，RestfulAPI資料存取，播放的單例設計模式，。<br>
 <br>
參考網站：https://courses.iosacademy.io/p/build-spotify-ios-app-swift-2021 <br>
 <br>
 
## 內容：

### 使用架構：MVVM 
### 使用語言：Swift 

### 實踐項目:
* API GET DELETE POST 使用
* collectionView頁面
* JSON資料解析
* Token資料獲取 更新



 

### 使用功能：
* UIKit
* WebKit
* CollectionView - Compositional Layout 

### 個人目錄：

 let group = DispatchGroup()  group.enter()  group.leave()   / HomeViewController  <br>
 <br>
 collectionView 標題 / HomeViewController  <br>
 <br>
 scrollView / LibraryViewController <br>
 <br>
 addChild didMove(toParent: self) /  LibraryViewController <br>
 <br>
 modalPresentationStyle = .fullScreen. / WelcomeViewController   <br>
 <br>
 WebKit / AuthViewController  <br>
 <br>
 登入成功後擷取url回傳的code  /AuthViewController  <br>
 <br>
 delegate / PlayerControlsView.  PlayerViewController.  PlaybackPresenter
