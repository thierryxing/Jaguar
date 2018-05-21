# 安装环境

## 操作系统
因为iOS编译及打包需要依赖Xcode，所以需要Mac OS 10.9+系统，有条件的公司可以直接上Mac Pro，当然Mac Mini也是可以的，但是建议高配版+SSD。

## Ruby&Rails
Jaguar本身是基于Ruby on Rails开发的，需要Ruby2.3环境（2.4+理论上也可以，但是没有测试过），Rails使用的是5.1.6版本。

## 数据库
Jaguar使用的是MySQL5.6版本

## Redis and Sidekiq
自动化异步任务全部跑在Sidekiq上，Sidekiq本身需要Redis作为存储，所以需要安装Redis。


# 安装指南

## Ruby
由于Mac系统自带的Ruby是2.0.*版本的，比较老，所以需要手动安装一下2.3版本。这里推荐使用RVM进行安装。

1. 安装RVM：

> curl -sSL https://get.rvm.io | bash -s stable

