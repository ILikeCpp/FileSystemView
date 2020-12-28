#ifndef FILESYSTEMMODEL_H
#define FILESYSTEMMODEL_H

#include <QFileSystemModel>
#include <QJsonObject>
#include <QJsonArray>

class FileSystemModel : public QFileSystemModel
{
    Q_OBJECT
public:
    explicit FileSystemModel(QObject *parent = nullptr);

    Q_INVOKABLE QString getFilePath(QModelIndex index);
    Q_INVOKABLE QJsonArray getFileArray(QModelIndex index);
    Q_INVOKABLE void openFile(QString file);
    Q_INVOKABLE QJsonObject addNewFile(QString dir);
    Q_INVOKABLE bool removeFile(QString file);
    Q_INVOKABLE bool renameFile(QString file, QString newName);
    Q_INVOKABLE bool cutFile(QString dir, QString file);
    Q_INVOKABLE bool copyFile(QString dir, QString file);
    Q_INVOKABLE QStringList getSuffixArray(QModelIndex index);
    Q_INVOKABLE QJsonArray getFileArrayBySuffix(QModelIndex index, QString compareSuffix);

signals:

public slots:

private:
    QString findIcon(QString suffix);
};

#endif // FILESYSTEMMODEL_H
