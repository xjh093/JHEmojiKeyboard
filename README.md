# JHEmojiKeyboard
Emoji Keyboard
- Emoji 表情键盘

---

# What

![image](https://github.com/xjh093/JHEmojiKeyboard/blob/master/JHEmojiKeyboard/image/gif.gif)

---

# Usage

```
    JHEmojiPadConfig *config = [[JHEmojiPadConfig alloc] init];
    config.emojiType = JHEmojiType_Face1;
    config.topOffset = 10;
    JHEmojiPadView *emojiPad = [[JHEmojiPadView alloc] initWithFrame:CGRectMake(0, 100, kScreenWidth, 200) config:config];
    emojiPad.emojiClickBlock = ^(NSString *face, NSString *text) {
        NSLog(@"表情图片：%@，表情内容：%@",face,text);
    };

    textView.inputView = emojiPad;
```
---

# Logs
### 2018-05-15
1.upload.
