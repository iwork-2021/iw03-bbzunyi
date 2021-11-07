# IOS开发ITSC


## 一、效果展示

功能展示如下：

主界面

![主界面](https://raw.githubusercontent.com/iwork-2021/iw03-bbzunyi/main/pics/MainInterface.png)

新闻内容界面

![新闻内容界面](https://raw.githubusercontent.com/iwork-2021/iw03-bbzunyi/main/pics/NewsWindow.png)

关于界面

![关于界面](https://raw.githubusercontent.com/iwork-2021/iw03-bbzunyi/main/pics/AboutUs.png)

结果展示：已经发到qq群里



## 二、实验中遇到的问题：

1、界面跳转的问题

​	这次面临很多界面的跳转，使用的是曹老师提供的Toolbar Controller和navigation controller来实现各种界面的跳转。首先遇到segue直接跳转不会初始化界面然后报错的问题，这里询问了曹老师然后上网查了很多资料，最后用pushViewController（先` _ = contentViewController.view`初始化一下）解决了这一问题。

```swift
   let contentViewController = self.storyboard!.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController//segue.destination as! ContentViewController
        let item = News[indexPath.row]
        _ = contentViewController.view
        print(item.title)
        //contentViewController.title1.text = item.title
        navigationController?.pushViewController(contentViewController, animated: true)
        contentViewController.loadhtml(news_item: item)
```

2、界面跳转问题2

​	用以上方式跳转的界面不会像navigation controller创建的界面一样，不会隐藏tool bar，所以需要手动在加载页面时隐藏和显示工具栏。

```swift
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        //navigationController?.setToolbarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
       // navigationController?.setToolbarHidden(false, animated: animated)
    }
```



3、解析html文件问题

​	这里引入了SwiftSoup库，使用SwiftSoup来解析这一文件，然后利用里面提供的工具来提取我们需要的内容。（给出一点例子）

```swift
  let document = try SwiftSoup.parse(self.html)
  let title = try document.title()
  let pics: Elements = try document.select("img[src]")
```



4、访问url问题

​	利用的是URLSession来访问url，里面也适用了GCD并发编程来控制运行，代码如下：

```swift
let url = URL(string: news_item.website)!
let task = URLSession.shared.dataTask(with: url, completionHandler: {
  data, response, error in
  if let error = error {
    print("\(error.localizedDescription)")
    return
  }
  guard let httpResponse = response as? HTTPURLResponse,
  (200...299).contains(httpResponse.statusCode) else {
    print("server error")
    return
  }
  if let mimeType = httpResponse.mimeType, mimeType == "text/html",
  let data = data,
  let string = String(data: data, encoding: .utf8) {
    DispatchQueue.main.sync {
      self.html = string
      //print(string)
      self.loadContent()
    }
  }
})
task.resume()
```

5、使用gcd编程仍会面临顺序不一致的情况，所以在访问网站时，我选择读取一页通知后sleep 0.4s，以保证顺序的一致

```swift
super.viewDidLoad()
       // self.setPageNum()
let queue = DispatchQueue(label: "com.table")
queue.sync {
  for j in 0..<self.page_num {
    self.downloadhtml(page:j)
    usleep(400000)
    // print(j)
  }
}
```

6、label之间会相互覆盖的问题

​	使用textfield实现文件标题，并改为不能编辑模式，就可以像label一样，但是控制显示的范围

```swift
@IBOutlet weak var title: UITextField!
@IBOutlet weak var date: UILabel!

override func awakeFromNib() {
  title.borderStyle = .none
  title.isEnabled = false
  super.awakeFromNib()
  // Initialization code
}
```



## 三、感想与体会

​	这次实验是三次实验中最难的一次吧，因为没有教程，只能自己一点一点去学习，但还好老师提供了一个模版项目，toolbar和navigation controller不需要自己去连接，也相当于在让我们发挥想象力的同时，为我们奠定了基础。然后整个过程从读取url开始，到解析，到把解析的内容实现在view上，是复杂但是能学习到很多东西的过程。比如解析的过程，一开始不知道怎样去做，但是找到了一个Readme比较详细的库，里面提供了很多有效解析的工具，简化了分析字符串的过程，加深了对html语言的理解。然后就是显示的问题，这一过程既要注意美观，也要注意项目的可视性，所以在中和的过程中也加强了对xcode和swift语言的使用，总体来说受益匪浅，在下一实验中也会继续学习。