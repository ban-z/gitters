import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:gitters/application.dart';
import 'package:gitters/business/widgets/toast.dart';
import 'package:gitters/framework/global/constants/Constant.dart';
import 'package:gitters/framework/global/constants/language/Localizations.dart';
import 'package:gitters/framework/network/Git.dart';
import 'package:gitters/framework/router/RouterConfig.dart';
import 'package:gitters/framework/utils/I18n.dart';
import 'package:gitters/models/user.dart';

class LoginPage extends StatefulWidget {
  @override
  createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController pwdController = new TextEditingController();
  bool passwordVisible = false; //密码是否显示明文
  GlobalKey formKey = new GlobalKey<FormState>();
  bool nameAutoFocus = true;

  @override
  void initState() {
    nameController.text = diskCache.getString(Constant.USER_NAME) ?? '';
    pwdController.text = diskCache.getString(Constant.PASSWORD) ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(GittersLocalizations.of(context).ApplicationName),
          leading: Text(''),
          actions: [
            IconButton(
                icon: Icon(Icons.language),
                onPressed: () {
                  changeLanguage(context);
                })
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              margin: EdgeInsets.only(top: 24.0, left: 12.0, right: 12.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(24.0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello Gitter',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontStyle: FontStyle.italic),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                  Image.asset("images/gitters-logo.png", //头像占位图，加载过程中显示
                      width: 96.0,
                      height: 96.0),
                ],
              ),
              // transform: Matrix4.rotationZ(0.00),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 248.0),
              child: Form(
                  key: formKey,
                  autovalidate: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                          autofocus: nameAutoFocus,
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText:
                                GittersLocalizations.of(context).HintAccount,
                            hintText: GittersLocalizations.of(context)
                                .HintInputAccount,
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) {
                            return v.trim().isNotEmpty
                                ? null
                                : GittersLocalizations.of(context)
                                    .WarningNullAccount;
                          }),
                      TextFormField(
                        autofocus: !nameAutoFocus,
                        controller: pwdController,
                        decoration: InputDecoration(
                            labelText:
                                GittersLocalizations.of(context).HintPassword,
                            hintText: GittersLocalizations.of(context)
                                .HintInputPassword,
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            )),
                        obscureText: !passwordVisible,
                        validator: (v) {
                          return v.trim().isNotEmpty
                              ? null
                              : GittersLocalizations.of(context)
                                  .WarningNullPassword;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints.expand(height: 55.0, width: 248.0),
                          child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: _onLogin,
                            textColor: Colors.white,
                            child: Text(
                                GittersLocalizations.of(context).LoginContent),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 32.0),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                GestureDetector(
                  onTap: () {
                    onUserHelperClick(context);
                  },
                  child: Text(GittersLocalizations.of(context).LoginProblem),
                ),
                Text(' | '),
                GestureDetector(
                  onTap: () {
                    fluroRouter.navigateTo(
                        context, RouterList.AboutGitHubApp.value);
                  },
                  child: Text(GittersLocalizations.of(context).AboutGitters),
                ),
              ]),
            )
          ],
        ));
  }

  void _onLogin() async {
    // 登录前，验证各个表单字段是否合法
    if ((formKey.currentState as FormState).validate()) {
      showLoading(context);
      GNUser user;
      try {
        user =
            await Git(context).login(nameController.text, pwdController.text);
      } catch (e) {
        //登录失败则提示
        if (e.response?.statusCode == 401) {
          showToast("客户端错误，请重试...");
        } else {
          showToast(e.toString());
        }
      } finally {
        // 隐藏loading框
        Navigator.of(context).pop();
      }

      // TODO:login方法在1114不能使用，问题已查，安全合规，必须使用Token为密码登录
      if (user != null) {
        // 存储用户名与密码
        diskCache.setString(Constant.USER_NAME, nameController.text);
        diskCache.setString(Constant.PASSWORD, pwdController.text);
        // 创建gitHubClient
        gitHubClient = GitHub(
            auth:
                Authentication.basic(nameController.text, pwdController.text));
        // 隐藏loading框
        fluroRouter.pop(context);
        fluroRouter.navigateTo(context, RouterList.Home.value);
      } else {
        // 隐藏loading框
        // fluroRouter.pop(context); // finally 中已经执行过了
        showToast("用户名或密码错误，请重试...");
      }
    }
  }

  void onUserHelperClick(BuildContext context) {
    fluroRouter.navigateTo(context, RouterList.UserHelperCenter.value);
  }

  void onAppInfoClick(BuildContext context) {
    fluroRouter.navigateTo(context, null);
  }
}
