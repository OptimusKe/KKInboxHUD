
KKInboxHUD ![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)
==========
模仿Google Inbox App HUD

Demo
==========
![Alt text](http://i.imgur.com/4SBfVQX.gif)

#Example Usage

First

```
#import "KKInboxHUD.h"
```

Then 

```
KKInboxHUD *hud = [[KKInboxHUD alloc] initWithFrame:frame];
[self.view addSubview:hud];
```

Customize

```
/* 
   Default colors : google flat ui colors
   Default width  : 5.0f
*/
hud.customColors = @[[UIColor blueColor],[UIColor redColor],[UIColor yellowColor],[UIColor greenColor]];
hud.lineWidth = 10.0f;
```

Remove 

```
[hud removeFromSuperview];
```

## Requirements
* iOS 7 or later 
* XCode 6 and iOS 8 SDK

## Author

OptimusKe (yeah200077@gmail.com)

## License

MIT license. See the LICENSE file for more info.
