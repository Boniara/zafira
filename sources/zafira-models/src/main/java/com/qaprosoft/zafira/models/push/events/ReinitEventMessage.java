/*******************************************************************************
 * Copyright 2013-2019 Qaprosoft (http://www.qaprosoft.com).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/
package com.qaprosoft.zafira.models.push.events;

import com.qaprosoft.zafira.models.db.Setting;

public class ReinitEventMessage extends EventMessage {

    private static final long serialVersionUID = 5300913238106855128L;

    private Setting.Tool tool;

    public ReinitEventMessage(String tenancy, Setting.Tool tool) {
        super(tenancy);
        this.tool = tool;
    }

    public Setting.Tool getTool() {
        return tool;
    }

    public void setTool(Setting.Tool tool) {
        this.tool = tool;
    }

}
