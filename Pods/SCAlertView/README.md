# SCAlertView
支持富文本的alertView

## Usage

---
``` bash
            SCAlertView *alertView = [SCAlertView alertViewWithTitle:@"标题" message:@"副标题" style:SCAlertViewStyleAlert];
            SCAlertAction *action = [SCAlertAction actionWithTitle:@"确定" style:SCAlertActionStyleConfirm handler:^(SCAlertAction *action) {
                // action
            }];
            [alertView addAction:action];
            [alertView show];
```

## pod
---
pod 'SCAlertView',	:git => 'https://github.com/SeJasonWang/SCAlertView.git'