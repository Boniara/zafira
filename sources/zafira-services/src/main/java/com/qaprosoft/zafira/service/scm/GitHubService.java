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
package com.qaprosoft.zafira.service.scm;

import com.qaprosoft.zafira.models.db.ScmAccount;
import com.qaprosoft.zafira.models.dto.scm.Organization;
import com.qaprosoft.zafira.models.dto.scm.Repository;
import com.qaprosoft.zafira.service.CryptoService;
import com.qaprosoft.zafira.service.util.GitHubHttpUtils;
import org.apache.commons.lang3.StringUtils;
import org.kohsuke.github.GHPerson;
import org.kohsuke.github.GHRepository;
import org.kohsuke.github.GitHub;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class GitHubService implements IScmService {

    private static final Logger LOGGER = LoggerFactory.getLogger(GitHubService.class);

    private final GitHubHttpUtils gitHubHttpUtils;
    private final CryptoService cryptoService;
    private final String gitHubClientId;
    private final String gitHubSecret;

    public GitHubService(
            GitHubHttpUtils gitHubHttpUtils,
            CryptoService cryptoService,
            @Value("${github.client-id}") String gitHubClientId,
            @Value("${github.client-secret}") String gitHubSecret
    ) {
        this.gitHubHttpUtils = gitHubHttpUtils;
        this.cryptoService = cryptoService;
        this.gitHubClientId = gitHubClientId;
        this.gitHubSecret = gitHubSecret;
    }

    public String getAccessToken(String code) throws IOException, URISyntaxException {
        return this.gitHubHttpUtils.getAccessToken(code, this.gitHubClientId, this.gitHubSecret);
    }

    @Override
    public List<Repository> getRepositories(ScmAccount scmAccount, String organizationName, List<String> existingRepos) throws IOException {
        GitHub gitHub = connectToGitHub(scmAccount);
        GHPerson tokenOwner = gitHub.getMyself();
        GHPerson person = StringUtils.isBlank(organizationName) || tokenOwner.getLogin().equals(organizationName) ?
                gitHub.getMyself() : gitHub.getOrganization(organizationName);
        List<Repository> repositories = person.listRepositories().asList().stream()
                                              .filter(repository -> isRepositoryOwner(person.getLogin(), repository))
                                              .map(GitHubService::mapRepository).collect(Collectors.toList());
        return repositories.stream()
                           .filter(repository -> !existingRepos.contains(repository.getUrl()))
                           .collect(Collectors.toList());
    }

    @Override
    public Repository getRepository(ScmAccount scmAccount) {
        String organizationName = scmAccount.getOrganizationName();
        String repositoryName = scmAccount.getRepositoryName();
        GHRepository repository = null;
        if (!StringUtils.isBlank(organizationName) && !StringUtils.isBlank(repositoryName)) {
            try {
                GitHub gitHub = connectToGitHub(scmAccount);
                String repositoryAbsoluteName = organizationName + "/" + repositoryName;
                repository = gitHub.getRepository(repositoryAbsoluteName);
            } catch (IOException e) {
                LOGGER.error(e.getMessage(), e);
            }
        }
        return repository == null ? null : mapRepository(repository);
    }

    @Override
    public List<Organization> getOrganizations(ScmAccount scmAccount) throws IOException {
        GitHub gitHub = connectToGitHub(scmAccount);
        List<Organization> organizations = gitHub.getMyself().getAllOrganizations().stream().map(organization -> {
            Organization result = new Organization(organization.getLogin());
            result.setAvatarURL(organization.getAvatarUrl());
            return result;
        }).collect(Collectors.toList());
        Organization myself = new Organization(gitHub.getMyself().getLogin());
        myself.setAvatarURL(gitHub.getMyself().getAvatarUrl());
        organizations.add(myself);
        return organizations;
    }

    @Override
    public String getClientId() {
        return this.gitHubClientId;
    }

    @Override
    public String getLoginName(ScmAccount scmAccount) {
        String result = null;
        GitHub gitHub;
        try {
            gitHub = connectToGitHub(scmAccount);
            result = gitHub.getMyself().getLogin();
        } catch (IOException e) {
            LOGGER.error(e.getMessage(), e);
        }
        return result;
    }

    private static boolean isRepositoryOwner(String loginName, GHRepository repository) {
        boolean result = false;
        try {
            result = repository.getOwner().getLogin().equals(loginName);
        } catch (IOException e) {
            LOGGER.error(e.getMessage(), e);
        }
        return result;
    }

    private static Repository mapRepository(GHRepository repository) {
        Repository repo = new Repository(repository.getName());
        repo.setDefaultBranch(repository.getDefaultBranch());
        repo.setPrivate(repository.isPrivate());
        repo.setUrl(repository.getHtmlUrl().toString());
        return repo;
    }

    private GitHub connectToGitHub(ScmAccount scmAccount) throws IOException {
        String decryptedAccessToken = cryptoService.decrypt(scmAccount.getAccessToken());
        GitHub gitHub;
        switch (scmAccount.getName()) {
            case GITHUB:
                gitHub = GitHub.connectUsingOAuth(decryptedAccessToken);
                break;
            case GITHUB_ENTERPRISE:
                String apiUrl = scmAccount.getApiVersion();
                gitHub = GitHub.connectToEnterpriseWithOAuth(apiUrl, scmAccount.getLogin(), decryptedAccessToken);
                break;
            default:
                throw new IllegalStateException("Unexpected value: " + scmAccount.getName());
        }
        return gitHub;
    }
}
