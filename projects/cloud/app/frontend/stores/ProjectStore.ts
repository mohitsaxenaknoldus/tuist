import { ProjectQuery, ProjectDocument } from '@/graphql/types';
import { ApolloClient } from '@apollo/client';
import { makeAutoObservable, runInAction } from 'mobx';

interface Account {
  id: string;
  owner: User | Organization;
}

interface User {
  type: 'user';
  id: string;
}

interface Organization {
  type: 'organization';
  id: string;
}

interface S3Bucket {
  name: string;
  accessKeyId: string;
  secretAccessKey: string;
}

interface Project {
  account: Account;
  remoteCacheStorage: S3Bucket;
}

export default class ProjectStore {
  project: Project;
  client: ApolloClient<object>;
  constructor(client: ApolloClient<object>) {
    this.client = client;
    makeAutoObservable(this);
  }

  async load(name: string, accountName: string) {
    const { data } = await this.client.query({
      query: ProjectDocument,
      variables: {
        name,
        accountName,
      },
    });
    runInAction(() => {
      this.project = {
        account: {
          id: data.project.account.id,
          owner: {
            type:
              data.project.account.owner.__typename === 'Organization'
                ? 'organization'
                : 'user',
            id: data.project.account.owner.id,
          },
        },
        remoteCacheStorage: {
          name: data.project.remoteCacheStorage.bucketName,
          accessKeyId: data.project.remoteCacheStorage.accessKeyId,
          secretAccessKey:
            data.project.remoteCacheStorage.secretAccessKey,
        },
      };
      this.project = data.project;
    });
  }
}
