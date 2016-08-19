# UIExtension
UIAlertView与UIActionSheet的类扩展，可使用Bolck完成回调，无需实现代理方法
## 使用方法
将`UIAlertView+Block.swift`、`UIActionSheet+Block.swift`文件加入项目
使用构造方法创建UIAlertView或UIActionSheet（使用原生构造方法亦可）：

```
let alertView = UIAlertView(title: "title", message: "message", style: .Default, cancelButtonTitle: "cancel", otherButtonTitles: ["btn1","btn2"]) { (alertView, buttonIndex) in
	print("tapBlock")
}
alertView.show()

let actionsheet = UIActionSheet(title: "title", cancelButtonTitle: "cancel", destructiveButtonTitle: "destructive", otherButtonTitles: ["btn1","btn2"]) { (actionSheet, buttonIndex) in
	print("tapBlock")
}
actionsheet.showInView(self.view)
        
```
构造方法后缀的Block为`tapBlock`，对应的代理方法为`clickedButtonAtIndex`。每个代理方法都对应一个Block。其中：

`tapBlock` : 对应 `clickedButtonAtIndex`方法

`willPresentBlock` : 对应 `willPresentAlertView`、`willPresentActionSheet`方法

`didPresentBlock` : 对应 `didPresentAlertView`、`didPresentActionSheet`方法

`willDismissBlock` : 对应 `willDismissWithButtonIndex`方法

`didDismissBlock` : 对应 `didDismissWithButtonIndex`方法

`cancelBlock` : 对应 `alertViewCancel`、`actionSheetCancel`方法

`shouldEnableFirstOtherButtonBlock` : 对应 `alertViewShouldEnableFirstOtherButton`方法

为alertView或actionSheet添加Block：

```
alertView.didDismissBlock { (alertView, buttonIndex) in
            // do something
}
actionsheet.cancelBlock { (actionSheet) in
            // do something
}
actionsheet.didDismissBlock { (actionSheet, buttonIndex) in
            // do something
}
```

## 注意
若指定代理并实现代理方法，除`alertViewShouldEnableFirstOtherButton`方法外支持既执行block回调也执行代理方法回调，`alertViewShouldEnableFirstOtherButton`方法只能实现一个回调，并以Block回调优先。

