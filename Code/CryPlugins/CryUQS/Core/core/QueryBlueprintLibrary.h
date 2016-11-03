// Copyright 2001-2016 Crytek GmbH / Crytek Group. All rights reserved.

#pragma once

// *INDENT-OFF* - <hard to read code and declarations due to inconsistent indentation>

namespace uqs
{
	namespace core
	{

		//===================================================================================
		//
		// CQueryBlueprintLibrary
		//
		//===================================================================================

		class CQueryBlueprintLibrary : public IQueryBlueprintLibrary
		{
		private:
			struct SCaseInsensitiveStringLess
			{
				bool operator()(const string& a, const string& b) const { return a.compareNoCase(b) < 0; }
			};

		public:
			explicit                                              CQueryBlueprintLibrary();

			virtual ELoadAndStoreResult                           LoadAndStoreQueryBlueprint(ELoadAndStoreOverwriteBehavior overwriteBehavior, datasource::IQueryBlueprintLoader& loader, shared::IUqsString& error) override;
			virtual bool                                          RemoveStoredQueryBlueprint(const char*szQueryBlueprintName, shared::IUqsString& error) override;

			std::shared_ptr<const CQueryBlueprint>                FindQueryBlueprintByName(const char* queryBlueprintName) const;
			void                                                  PrintToConsole(CLogger& logger) const;

		private:
			                                                      UQS_NON_COPYABLE(CQueryBlueprintLibrary);

		private:
			std::map<string, std::shared_ptr<CQueryBlueprint>, SCaseInsensitiveStringLess>    m_library;
		};

	}
}
