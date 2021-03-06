/*******************************************************************************
 * Copyright 2013-2019 Qaprosoft (http://www.qaprosoft.com).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/
package com.qaprosoft.zafira.service.integration;

import com.qaprosoft.zafira.models.db.Job;
import com.qaprosoft.zafira.models.entity.integration.Integration;
import com.qaprosoft.zafira.models.entity.integration.IntegrationInfo;

import java.util.List;
import java.util.Map;

public interface IntegrationService {

    Integration create(Integration integration, Long integrationTypeId);

    Integration retrieveById(Long id);

    Integration retrieveByBackReferenceId(String backReferenceId);

    Integration retrieveByJobAndIntegrationTypeName(Job job, String integrationTypeName);

    Integration retrieveDefaultByIntegrationTypeId(Long integrationTypeId);

    Integration retrieveDefaultByIntegrationTypeName(String integrationTypeName);

    List<Integration> retrieveAll();

    List<Integration> retrieveIntegrationsByTypeId(Long typeId);

    List<Integration> retrieveIntegrationsByGroupId(Long groupId);

    List<Integration> retrieveIntegrationsByGroupName(String integrationGroupName);

    List<Integration> retrieveByIntegrationsTypeName(String integrationTypeName);

    Map<String, Map<String, List<IntegrationInfo>>> retrieveInfo();

    IntegrationInfo retrieveInfoByIntegrationId(String groupName, Long id);

    IntegrationInfo retrieveInfoByIntegration(Integration integration);

    Integration update(Integration integration);

}
