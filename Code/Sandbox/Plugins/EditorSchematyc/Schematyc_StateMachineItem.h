// Copyright 2001-2016 Crytek GmbH / Crytek Group. All rights reserved.

#pragma once

#include "Schematyc_AbstractObjectItem.h"

#include <QString>
#include <QIcon>

namespace Schematyc {

struct IScriptStateMachine;

}

namespace CrySchematycEditor {

class CStateItem;

class CStateMachineItem : public CAbstractObjectStructureModelItem
{
public:
	CStateMachineItem(Schematyc::IScriptStateMachine& scriptStateMachine, CAbstractObjectStructureModel& model);
	virtual ~CStateMachineItem();

	// CAbstractObjectStructureModelItem
	virtual void                               SetName(QString name) override;
	virtual int32                              GetType() const override          { return eObjectItemType_StateMachine; }

	virtual const QIcon*                       GetIcon() const override          { return &s_icon; }
	virtual CAbstractObjectStructureModelItem* GetParentItem() const override    { return static_cast<CAbstractObjectStructureModelItem*>(m_pParentItem); }

	virtual uint32                             GetNumChildItems() const override { return GetNumStates(); }
	virtual CAbstractObjectStructureModelItem* GetChildItemByIndex(uint32 index) const override;
	virtual uint32                             GetChildItemIndex(const CAbstractObjectStructureModelItem& item) const override;

	virtual uint32                             GetIndex() const;
	virtual void                               Serialize(Serialization::IArchive& archive) override;

	virtual bool                               AllowsRenaming() const override;
	// ~CAbstractObjectStructureModelItem

	void             SetParentItem(CAbstractObjectStructureModelItem* pParentItem) { m_pParentItem = pParentItem; }

	uint32           GetNumStates() const                                          { return m_states.size(); }
	CStateItem*      GetStateItemByIndex(uint32 index) const;
	CStateItem*      CreateState();
	bool             RemoveState();

	Schematyc::SGUID GetGUID() const;

protected:
	void LoadFromScriptElement();

private:
	static QIcon                       s_icon;

	CAbstractObjectStructureModelItem* m_pParentItem;
	Schematyc::IScriptStateMachine&    m_scriptStateMachine;
	std::vector<CStateItem*>           m_states;
};

}
