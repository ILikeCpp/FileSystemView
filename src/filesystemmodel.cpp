#include "filesystemmodel.h"
#include <QDebug>
#include <QFileIconProvider>
#include <QDesktopServices>
#include <QUrl>
#include <QDateTime>

FileSystemModel::FileSystemModel(QObject *parent) : QFileSystemModel(parent)
{

}

QString FileSystemModel::getFilePath(QModelIndex index)
{
    return this->filePath(index);
}

QJsonArray FileSystemModel::getFileArray(QModelIndex index)
{
    QString dirPath = this->filePath(index);

    QDir dir(dirPath);

    QFileInfoList infoList = dir.entryInfoList(QDir::Files);

    QJsonArray array;

    foreach (QFileInfo info, infoList) {
        //获取文件名称
        QString fileName = info.baseName();
        //后缀
        QString suffix = info.suffix();

        //查找图标
        QString icon = findIcon(suffix);
        if (icon.isEmpty())
        {
            QFileIconProvider provider;
            provider.icon(info).pixmap(QSize(32,32)).save(QString("icon_%1.png").arg(suffix));

            QFileInfo iconInfo(QString("icon_%1.png").arg(suffix));
            icon = "file:///";
            icon += iconInfo.absoluteFilePath();
        }

        qDebug() << "icon="<<icon;

        QJsonObject obj;
        obj.insert("fileName",fileName);
        obj.insert("icon",icon);
        obj.insert("filePath",info.absoluteFilePath());

        array.append(obj);
    }

    return array;
}

void FileSystemModel::openFile(QString file)
{
    QUrl url = QUrl::fromLocalFile(file);
    QDesktopServices::openUrl(url);
}

QJsonObject FileSystemModel::addNewFile(QString dir)
{
    QString fileName = QString("%1/新建文本_%2.txt").arg(dir).arg(QDateTime::currentDateTime().toString("yyyy_MM_dd_hh_mm_ss"));
    QFile file(fileName);
    file.open(QIODevice::WriteOnly);
    file.close();

    QFileInfo info(fileName);
    QString icon = findIcon(info.suffix());
    if (icon.isEmpty())
    {
        QFileIconProvider provider;
        provider.icon(info).pixmap(QSize(32,32)).save(QString("icon_%1.png").arg(info.suffix()));

        QFileInfo iconInfo(QString("icon_%1.png").arg(info.suffix()));
        icon = "file:///";
        icon += iconInfo.absoluteFilePath();
    }

    QJsonObject obj;
    obj.insert("fileName",info.baseName());
    obj.insert("icon",icon);
    obj.insert("filePath",info.absoluteFilePath());

    return obj;
}

bool FileSystemModel::removeFile(QString file)
{
    return QFile::remove(file);
}

bool FileSystemModel::renameFile(QString file, QString newName)
{
    QFileInfo info(file);
    QString newPath = info.absoluteDir().absolutePath()+"/"+newName+"."+info.suffix();

    return QFile::rename(file,newPath);
}

bool FileSystemModel::cutFile(QString dir, QString file)
{
    QFileInfo info(file);

    if (dir == info.absoluteDir().absolutePath())
    {
        return false;
    }

    qDebug() << "dir=" << dir;

    QString newFilePath = dir + "/" + info.completeBaseName()+"."+info.suffix();

    qDebug() << "newFilePath="<<newFilePath;

    if(QFile::copy(file, newFilePath))
    {
        return QFile::remove(file);
    }

    return false;
}

bool FileSystemModel::copyFile(QString dir, QString file)
{
    QFileInfo info(file);

    if (dir == info.absoluteDir().absolutePath())
    {
        QString newFilePath = dir + "/" + info.completeBaseName()+ "_"
                + QDateTime::currentDateTime().toString("yyyy_MM_dd_hh_mm_ss") + "."+info.suffix();

        qDebug() << "newFilePath="<<newFilePath;

        return QFile::copy(file, newFilePath);
    }
    else
    {
        qDebug() << "dir=" << dir;

        QString newFilePath = dir + "/" + info.completeBaseName()+"."+info.suffix();

        qDebug() << "newFilePath="<<newFilePath;

        if(QFile::copy(file, newFilePath))
        {
            return QFile::remove(file);
        }
    }



    return false;
}

QStringList FileSystemModel::getSuffixArray(QModelIndex index)
{
    QString dirPath = this->filePath(index);

    QDir dir(dirPath);

    QFileInfoList infoList = dir.entryInfoList(QDir::Files);

    QStringList list;
    list << "*.*";

    foreach (QFileInfo info, infoList) {
        //后缀
        QString suffix = info.suffix();
        if (suffix.isEmpty())
        {
            continue;
        }

        suffix = QString("*.%1").arg(suffix);

        if (list.contains(suffix))
        {
            continue;
        }
        list << suffix;
    }

    return list;
}

QJsonArray FileSystemModel::getFileArrayBySuffix(QModelIndex index, QString compareSuffix)
{
    QString dirPath = this->filePath(index);

    QDir dir(dirPath);

    QFileInfoList infoList = dir.entryInfoList(QDir::Files);

    QJsonArray array;

    foreach (QFileInfo info, infoList) {
        //获取文件名称
        QString fileName = info.baseName();
        //后缀
        QString suffix = info.suffix();

        if (compareSuffix == "*.*")
        {
            //do nothing
        }
        else if (compareSuffix != QString("*.%1").arg(suffix))
        {
            continue;
        }

        //查找图标
        QString icon = findIcon(suffix);
        if (icon.isEmpty())
        {
            QFileIconProvider provider;
            provider.icon(info).pixmap(QSize(32,32)).save(QString("icon_%1.png").arg(suffix));

            QFileInfo iconInfo(QString("icon_%1.png").arg(suffix));
            icon = "file:///";
            icon += iconInfo.absoluteFilePath();
        }

        qDebug() << "icon="<<icon;

        QJsonObject obj;
        obj.insert("fileName",fileName);
        obj.insert("icon",icon);
        obj.insert("filePath",info.absoluteFilePath());

        array.append(obj);
    }

    return array;
}

QString FileSystemModel::findIcon(QString suffix)
{
    QDir dir("./");
    QFileInfoList infoList = dir.entryInfoList(QStringList()<<"*.png", QDir::Files);
    foreach (QFileInfo info, infoList) {
        if (info.baseName().contains(QString("icon_%1").arg(suffix)))
        {
            QString icon = "file:///";
            icon += info.absoluteFilePath();
            return icon;
        }
    }

    return QString("");
}
