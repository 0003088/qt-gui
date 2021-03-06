#ifndef CONFIGNODE_H
#define CONFIGNODE_H

#include <QObject>
#include <QVariant>
#include <kdb.hpp>
#include <keyio.hpp>
#include <cassert>

#include "treeviewmodel.hpp"
#include "printvisitor.hpp"

class TreeViewModel;
class PrintVisitor;

class ConfigNode : public QObject
{
    Q_OBJECT

public:

    explicit ConfigNode(const QString& name, const QString& path, const kdb::Key &key, TreeViewModel *parentModel);
    /// Needed by Qt
    ConfigNode(const ConfigNode& other);
    /// Needed by Qt
    ConfigNode();
    ~ConfigNode();

    /**
     * @brief Returns the number of children of this ConfigNode.
     * @return The number of children of this ConfigNode.
     */
    int                     getChildCount() const;

    /**
     * @brief Returns the name of this ConfigNode.
     * @return The name of this ConfigNode.
     */
    QString                 getName() const;

    /**
     * @brief Returns the path of this ConfigNode.
     * @return The path of this ConfigNode.
     */
    QString                 getPath() const;

    /**
     * @brief Returns the value of this ConfigNode.
     * @return The value of this ConfigNode.
     */
    QVariant                getValue() const;

    /**
     * @brief Rename this ConfigNode.
     * @param name The new name for this ConfigNode.
     */
    void                    setName(const QString& name);

    /**
     * @brief Change the value of this ConfigNode.
     * @param value The new value for this ConfigNode.
     */
    void                    setValue(const QVariant& value);

    /**
     * @brief Append a new child to this ConfigNode.
     * @param node The new child of this ConfigNode.
     */
    void                    appendChild(ConfigNode* node);

    /**
     * @brief Returns if this ConfigNode has a child with a certain name.
     * @param name The name of the child node.
     * @return True if this node has a child with a certain name.
     */
    bool                    hasChild(const QString& name) const;

    /**
     * @brief Get the children of this ConfigNode.
     * @return The children of this ConfigNode as model.
     */
    TreeViewModel*          getChildren() const;

    /**
     * @brief Get the metakeys of this ConfigNode.
     * @return The metakeys of this ConfigNode as model.
     */
    TreeViewModel*          getMetaKeys() const;

    /**
     * @brief Returns if the children of this ConfigNode have any children themselves.
     * @return True if no child of this ConfigNode has any children.
     */
    bool                    childrenHaveNoChildren() const;

    /**
     * @brief Returns a child with a certain name.
     * @param name The name of the child which is looked for.
     * @return The child with the given name if it is a child of this ConfigNode.
     */
    ConfigNode*             getChildByName(QString& name) const;

    /**
      * @brief Returns a child on a given index.
      * @param index The index of the wanted child.
      * @return The child on the given index.
      */
    Q_INVOKABLE ConfigNode*     getChildByIndex(int index) const;

                void            setPath(const QString &path);

                void            setMeta(const QString &name, const QVariant &value);
    Q_INVOKABLE void            setMeta(const QVariantMap &metaData);
    Q_INVOKABLE void            deleteMeta(const QString &name);

                void            accept(Visitor &visitor);
                kdb::Key        getKey() const;
                void            setKey(kdb::Key key);
                void            setKeyName(const QString &name);
                void            invalidateKey();
                void            deletePath(QStringList &path);
                int             getIndexByName(const QString &name);
                TreeViewModel*  getParentModel();
                void            setParentModel(TreeViewModel *parent);

private:
    // TODO: not needed if we hold the Key
    QString m_name;
    QString m_path;
    QVariant m_value;

    // that is the only part we need:
    kdb::Key m_key;
    TreeViewModel* m_children;
    TreeViewModel* m_metaData;
    TreeViewModel* m_parentModel;

    void populateMetaModel();
};

Q_DECLARE_METATYPE(ConfigNode)

#endif // CONFIGNODE_H
