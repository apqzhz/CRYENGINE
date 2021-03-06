// Copyright 2001-2016 Crytek GmbH / Crytek Group. All rights reserved.

#include "StdAfx.h"
#include "Schematyc_VariableItem.h"

#include "Schematyc_ObjectModel.h"
#include "Schematyc_StateItem.h"

#include <Schematyc/Script/Elements/Schematyc_IScriptVariable.h>
#include <Schematyc/SerializationUtils/Schematyc_ISerializationContext.h>

#include <QtUtil.h>
#include <QObject>

namespace CrySchematycEditor {

CVariableItem::CVariableItem(Schematyc::IScriptVariable& scriptVariable, CStateItem& state)
	: CAbstractVariablesModelItem(static_cast<CAbstractVariablesModel&>(state))
	, m_scriptVariable(scriptVariable)
	, m_owner(EOwner::State)
{

}

CVariableItem::CVariableItem(Schematyc::IScriptVariable& scriptVariable, CObjectModel& object)
	: CAbstractVariablesModelItem(static_cast<CAbstractVariablesModel&>(object))
	, m_scriptVariable(scriptVariable)
	, m_owner(EOwner::Object)
{

}

CVariableItem::~CVariableItem()
{

}

QString CVariableItem::GetName() const
{
	QString name = m_scriptVariable.GetName();
	return name;
}

void CVariableItem::SetName(QString name)
{
	Schematyc::CStackString uniqueName = QtUtil::ToString(name).c_str();
	// TODO: Unique in which scope?
	//Schematyc::ScriptBrowserUtils::MakeScriptElementNameUnique(uniqueName, m_model.GetScriptElement());
	// ~TODO

	m_scriptVariable.SetName(uniqueName.c_str());
	GetModel().SignalVariableInvalidated(*this);
}

void CVariableItem::Serialize(Serialization::IArchive& archive)
{
	// TODO: This will only work for serialization to properties in inspector!
	Schematyc::SSerializationContextParams serParams(archive, Schematyc::ESerializationPass::Edit);
	Schematyc::ISerializationContextPtr pSerializationContext = GetSchematycFramework().CreateSerializationContext(serParams);
	// ~TODO

	m_scriptVariable.Serialize(archive);
}

Schematyc::SGUID CVariableItem::GetGUID() const
{
	return m_scriptVariable.GetGUID();
}

}
