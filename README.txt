codeceptjsのお試し

IEでcodeceptjsを動かすために実行したもの。
Qiitaの記事をVagrant特有の処理は飛ばしてそのまま実行。

git cloneしてきたら

```
npm install codeceptjs --save-dev
```

を打てばたぶん動く（RUN.bat）ようになる

参考：
Vagrant + Selenium + node.js(CodeceptJS)でIE, Chrome, FirefoxのマルチブラウザE2Eテスト
https://qiita.com/uehatsu/items/71e584744f378b635baa


========================================
以下、Qiita記事の概要とメモ
========================================

====================
インストールが必要なもの
====================

[JRE](https://www.java.com/ja/download/manual.jsp)
[Selenium Server StandalneとIEDriverServer_Win64](https://www.seleniumhq.org/download/)
[ChromeとFirefox]()
[ChromeDriver](http://chromedriver.chromium.org/downloads)
[geckodriver]()

IEDriverServer.exe、chromedriver.exe、geckodriver.exeはそれぞれPATHの通っている場所に移動させる
（IEでテストしたいだけだったので、chromedriver.exeとgeckodriver.exeは使わなかった）

「%home%\workspace\try_codeceptjs」を作成してそこに移動させた。
後述する「npx codeceptjs init」その他もここで叩く。

====================
IEの設定
====================

IE > Internet Options > Security > （各ゾーン） > Enable Protected Modeのチェックを入れる
（これを実施しなかったときにコンソールに出る指示通り）

regedit.exeを起動し、以下のキーを作成

```reg
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BFCACHE]
"iexplore.exe"=dword:00000000
```

FEATURE_BFCACHEキーについてはここを参照（実質的にSelenium専用のキーらしい）
https://answers.microsoft.com/en-us/ie/forum/all/featurebfcache-in-ie11/b461e166-c1e0-4171-be93-aec65e9de727
（消しても動いたんだけど。。。）

====================
codeceptjsの準備
====================

```cmd
npm init -y
npm install codeceptjs --save-dev
npx codeceptjs init
npx codeceptjs gt
```

「npx codeceptjs init」後に追加で何かnpm installしたかも（コンソールに出た指示通り）
「npx codeceptjs init」の途中でブラウザを聞かれるので「internet explorer」と入力
「npx codeceptjs gt」では「github」と入力：テスト「github_test.js」が作成される

====================
テストの準備
====================

github_test.js を以下のように修正

```
Feature('Github');

Scenario('test something', (I) => {
  I.amOnPage('https://github.com');
  I.see('GitHub');
});
```

====================
テスト実行
====================

```cmd
start java -jar selenium-server-standalone-3.141.59.jar -role hub
start java -jar selenium-server-standalone-3.141.59.jar -role node -hub http://localhost:4444/grid/register
npx codeceptjs run --steps
```

javaコマンドでサーバーを立ち上げるので、java用のコンソールが2つ、npx用のコンソールが1つ必要

==================== 以下は未実施 ====================

====================
IE, Chrome, Firefoxを使い分ける
====================

`codecept.config.js`を修正する

```javascript
exports.config = {
  tests: './*_test.js',
  output: './output',
  helpers: {
    WebDriver: {
      url: 'http://localhost',
      browser: process.profile || 'internet explorer',
    }
  },
  include: {
    I: './steps_file.js'
  },
  bootstrap: null,
  mocha: {},
  name: 'test',
  translation: 'ja-JP'
}
```

====================
テスト起動
====================

```
$ npx codeceptjs run --steps
$ npx codeceptjs run --steps --profile 'internet explorer'
$ npx codeceptjs run --steps --profile chrome
$ npx codeceptjs run --steps --profile firefox
```

====================
npm run testで起動できるように設定
====================

`packege.json`を以下のように修正

```json
{
  "name": "test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "npm run test:ie; npm run test:chrome; npm run test:firefox;",
    "test:ie": "codeceptjs run --steps --profile 'internet explorer'",
    "test:chrome": "codeceptjs run --steps --profile chrome",
    "test:firefox": "codeceptjs run --steps --profile firefox"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "codeceptjs": "^2.0.6"
  }
}
```

====================
npm run testから起動
====================

```
$ npm run test:ie
$ npm run test:chrome
$ npm run test:firefox
$ npm run test
```

